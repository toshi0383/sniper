[![](http://img.shields.io/badge/Swift-2.1-orange.svg)]()

# sniper
OSX command line tool to manage other mac app like iPhoneSimulator

# usage

```
# List all running apps
$ sniper target
37 apps found.
com.apple.loginwindow: 89
.
.
.

# Filter by keyword
$ sniper target  firefox
1 app found.
org.mozilla.firefox: 4822

# Terminate process by bundle ID
$ ./sniper shot -b org.mozilla.firefox
Terminating org.mozilla.firefox: 4822 ...

# Terminate process by PID
$ sniper shot -p 4703
Terminating com.apple.iphonesimulator: 4703 ...
```

# install

Clone this repo and copy `./bin/sniper` to your $PATH .

# basic use case

Reset all simulators in your CI process.

```
$ sniper shot -b com.apple.iphonesimulator  # shutdown before reset(remove) all simulators
terminating com.apple.iphonesimulator ...
$ rm -rf ~/Library/Developer/CoreSimulator/Devices/*
```

