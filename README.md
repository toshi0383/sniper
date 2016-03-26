[![Build Status](https://www.bitrise.io/app/3039e5ad5401b34b.svg?token=IiYxTu5sGPTcbFKtyLpazA&branch=master)](https://www.bitrise.io/app/3039e5ad5401b34b)
[![](http://img.shields.io/badge/Swift-2.2-orange.svg)]()

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
$ ./sniper shoot -b org.mozilla.firefox
Terminating org.mozilla.firefox: 4822 ...

# Terminate process by PID
$ sniper shoot -p 4703
Terminating com.apple.iphonesimulator: 4703 ...
```

# install

Clone this repo and copy `./bin/sniper` to your $PATH .

# basic use case

Reset all simulators in your CI process.

```
$ sniper shoot -b com.apple.iphonesimulator  # shutdown before reset(remove) all simulators
terminating com.apple.iphonesimulator ...
$ rm -rf ~/Library/Developer/CoreSimulator/Devices/*
```

