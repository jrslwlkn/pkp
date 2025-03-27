#!/opt/homebrew/bin/bash

REFRESH_RATE=$(( 10*60 ))               # how often this runs in seconds
CPU_THRESHOLD=95                        # sustained CPU usage percentage
OFFENCE_DURATION=$(( 30*60 ))           # sustained time over CPU threshold in seconds

offence_threshold=$(( OFFENCE_DURATION / REFRESH_RATE ))
declare -A stats
declare -A excluded=(
  ["WindowServer"]=1
  ["kernel_task"]=1
  ["launchd"]=1
)
declare -A popup_q
popup_on=0

while true; do
  mapfile -t high_cpu < <(ps -axo pid=,pcpu=,command= | awk -v t="$CPU_THRESHOLD" '$2 >= t')

  for line in "${high_cpu[@]}"; do
    echo "$line"

    pid=$(awk '{print $1}' <<< "$line")
    cpu=$(awk '{print $2}' <<< "$line")
    cmd=$(awk '{$1=""; $2=""; sub(/^  */, ""); print}' <<< "$line")
    cmd=${cmd%% -*}
    process_name=$(basename "$cmd")

    [[ -z "$process_name" ]] && continue
    [[ ${excluded["$process_name"]} ]] && continue

    stats["$process_name"]=$(( stats["$process_name"] + 1 ))

    if [[ ${stats["$process_name"]} -ge $offence_threshold && "${popup_q["$cmd"]}" -eq "" ]]; then
      echo "---"
      echo "hit $process_name"
      echo "aka $cmd"
      echo "---"

      popup_q["$cmd"]=1
      if [[ $popup_on -eq 1 ]]; then
        continue
      fi

      popup_on=1
      user_name=$(stat -f%Su /dev/console)
      escaped_cmd=${cmd//\"/\\\"}

      result=$(sudo -u "$user_name" osascript -e "
        display alert \"High CPU Usage Detected\" \
        message \"Process \\\"$process_name\\\" (PID $pid) is using over $CPU_THRESHOLD% CPU.\n\nExecutable Path:\n$escaped_cmd\" \
        buttons {\"Cancel\", \"Kill\"} as warning")

      if echo "$result" | grep -q "Kill"; then
        pkill -9 "$process_name"
      fi
      stats["$process_name"]=0

      unset popup_q["$cmd"]
      popup_on=0
    fi
  done

  now=$(date +%s)
  if (( now % offence_threshold == 0 )); then
    for key in "${!stats[@]}"; do
      unset stats["$key"]
    done
    echo "@ $now clearing stats ${#stats[@]}"
  fi
  if (( now % (( REFRESH_RATE * 12 )) == 0 )); then
    for key in "${!popup_q[@]}"; do
      unset popup_q["$key"]
    done
    echo "@ $now clearing popup queue ${#popup_q[@]}"
  fi

  sleep "$REFRESH_RATE"
done

