//
//  main.swift
//  sniper
//
//  Created by toshi0383 on 11/6/15.
//  Copyright © 2015 toshi0383. All rights reserved.
//

import AppKit

let UnknownBundleID = "<unknown bundle ID>"

CLI.setup(name:"sniper", version: "1.0", description:"OSX command line app to terminate other app like iphonesimulator")
class Target: CommandType {
    let commandName = "target"
    let commandShortDescription = "List all running apps' bundle ids."
    let commandSignature = "[<keyword>]"

    func execute(arguments: CommandArguments) throws  {
        let keyword = arguments.optionalArgument("keyword")
        let apps = NSWorkspace.sharedWorkspace().runningApplications
        var filtered = [NSRunningApplication]()
        if let keyword = keyword {
            let regex = try! NSRegularExpression(pattern: "\(keyword)", options: .CaseInsensitive)
            filtered = apps.filter{
                guard let bundle = $0.bundleIdentifier else {
                    return false
                }
                return !regex.matchesInString(bundle,
                    options: NSMatchingOptions.WithTransparentBounds,
                    range: NSMakeRange(0, bundle.characters.count)).isEmpty
            }
        } else {
            filtered = apps
        }
        print("\(filtered.count) app\(filtered.count == 1 ? "" : "s") found.")
        for app in filtered {
            print("\(app.bundleIdentifier ?? UnknownBundleID): \(app.processIdentifier)")
        }
    }
}
class Shot: OptionCommandType {
    let commandName = "shot"
    let commandShortDescription = "Terminate the running app(s). You need to pass the exact bundleID or PID."
    let commandSignature = ""

    func setupOptions(options: Options) {
        options.onKeys(["-p", "--pid"]) { [unowned self] _, value in
            guard let pid = Int(value) else {
                print("invalid pid")
                return
            }
            let apps = NSWorkspace.sharedWorkspace().runningApplications
            let filtered = apps.filter {
                Int($0.processIdentifier) == pid
            }
            guard !filtered.isEmpty else {
                print("Couldn't find any processes with pid \"\(pid)\"\nexiting...")
                return
            }
            filtered.forEach(self.terminate)
        }
        options.onKeys(["-b", "--bundle-id"]) { [unowned self] _, value in
            let bundleId = value
            let apps = NSRunningApplication.runningApplicationsWithBundleIdentifier(bundleId)
            guard !apps.isEmpty else {
                print("Couldn't find any processes named \"\(bundleId)\"\nexiting...")
                return
            }
            apps.forEach(self.terminate)
        }
    }
    func terminate(app:NSRunningApplication) {
        print("Terminating \(app.bundleIdentifier ?? UnknownBundleID): \(app.processIdentifier) ...")
        app.terminate()
    }
    func execute(arguments: CommandArguments) throws  {
    }
}

CLI.registerCommand(Target())
CLI.registerCommand(Shot())
let result = CLI.go()
exit(result)



