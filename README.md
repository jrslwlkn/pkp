# pkp: Process-Killing Process

I made this so that the big brother's runaway corporate processes are not draining my mac's battery. It will open a popup as notification and won't do anything on its own. See the script to tweak some parameters. Use at your own risk.

## Installation & Usage

We need GNU bash (or as I've recently taken to calling it, GNU+bash), then we copy the launch config file, make it owned by root (since the service should be able to kill processes owned by root), and load the daemon.

```bash
brew install bash
git clone https://github.com/jrslwlkn/pkp
cd pkp
sudo cp pkp.sh /usr/local/bin
sudo chmod +x /usr/local/bin/pkp.sh
sudo cp com.jrslwlkn.pkp.plist /Library/LaunchDaemons
sudo chown root:wheel /Library/LaunchDaemons/com.jrslwlkn.pkp.plist
sudo chmod 644 /Library/LaunchDaemons/com.jrslwlkn.pkp.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/com.jrslwlkn.pkp.plist
```

## Uninstallation

Same as above but in reverse.

```bash
sudo launchctl bootout system /Library/LaunchDaemons/com.jrslwlkn.pkp.plist
sudo rm /Library/LaunchDaemons/com.jrslwlkn.pkp.plist /usr/local/bin/pkp.sh
```

