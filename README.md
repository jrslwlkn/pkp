# pkp: Process-Killing Process

I made this so that the big brother's runaway corporate processes are not draining my mac's battery. It will open a popup as notification and won't do anything on its own. See the script to tweak some parameters. Use at your own risk.

## Installation & Usage

We need GNU bash (or as I've recently taken to calling it, GNU+bash), then we copy the launch config file, make it owned by root (since the service should be able to kill processes owned by root), and load the daemon.

```sh
brew install bash
sudo cp com.jrslwlkn.pkp.plist /Library/LaunchDaemons
sudo chown root:wheel /Library/LaunchDaemons/com.jrslwlkn.pkp.plist
sudo chmod 644 /Library/LaunchDaemons/com.jrslwlkn.pkp.plist
sudo launchctl load /Library/LaunchDaemons/com.jrslwlkn.pkp.plist
```

