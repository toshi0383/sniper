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

$ sniper target  firefox
1 app found.
org.mozilla.firefox: 4822

$ ./sniper shoot -b org.mozilla.firefox
Terminating org.mozilla.firefox: 4822 ...

$ sniper shoot -p 4703
Terminating com.apple.iphonesimulator: 4703 ...

$ sniper shoot -p 4703 -f
Terminating com.apple.iphonesimulator: 4703 ...
```

# install

Clone this repo and copy `./bin/sniper` to your $PATH .

