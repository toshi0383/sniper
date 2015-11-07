//
//  main.swift
//  sniper
//
//  Created by toshi0383 on 11/6/15.
//  Copyright © 2015 toshi0383. All rights reserved.
//

import AppKit

let UnknownBundleID = "<unknown bundle ID>"

CLI.setup(
           name: "sniper",
        version: "1.0.1",
    description: "the OSX app terminator"
)
class Target: CommandType {
    let commandName = "target"
    let commandShortDescription = "List all running apps's info."
    let commandSignature = "[<keyword>]"

    func execute(arguments: CommandArguments) throws  {
        let keyword = arguments.optionalArgument("keyword")
        let apps = getApps(keyword)
        print("\(apps.count) app\(apps.count == 1 ? "" : "s") found.")
        for app in apps {
            print("\(app.bundleIdentifier ?? UnknownBundleID): \(app.processIdentifier)")
        }
    }
    func getApps(keyword:String? = nil) -> [NSRunningApplication] {
        let apps = NSWorkspace.sharedWorkspace().runningApplications
        switch keyword {
        case .None:
            return apps
        case .Some(let keyword):
            let regex = try! NSRegularExpression(pattern: "\(keyword)", options: .CaseInsensitive)
            return apps.filter{
                guard let bundle = $0.bundleIdentifier else {
                    return false
                }
                return !regex.matchesInString(bundle,
                    options: NSMatchingOptions.WithTransparentBounds,
                    range: NSMakeRange(0, bundle.characters.count)).isEmpty
            }
        }
    }
}
class Shot: OptionCommandType {
    let commandName = "shot"
    let commandShortDescription = "Terminate the specified running app. You need to pass the exact bundleID or PID."
    let commandSignature = ""

    var pid:Int?
    var bundleId:String?

    func setupOptions(options: Options) {
        options.onKeys(["-p", "--pid"]) { [unowned self] _, value in
            guard let pid = Int(value) else {
                print("invalid pid: \(value)")
                return
            }
            self.pid = pid
        }
        options.onKeys(["-b", "--bundle-id"]) { [unowned self] _, value in
            self.bundleId = value
        }
    }
    func terminate(app:NSRunningApplication) {
        print("Terminating \(app.bundleIdentifier ?? UnknownBundleID): \(app.processIdentifier) ...")
        app.terminate()
    }
    enum SniperError: ErrorType {
        case InvalidArgument, TargetNotFound
    }
    func execute(arguments: CommandArguments) throws  {
        if let _ = pid, _ = bundleId {
            print("Cannot specify both bundleID(-b) and PID(-p) at the same time.")
            throw SniperError.InvalidArgument
        }
        if let pid = pid {
            let apps = NSWorkspace.sharedWorkspace().runningApplications
            let filtered = apps.filter {
                Int($0.processIdentifier) == pid
            }
            guard !filtered.isEmpty else {
                print("Couldn't find any processes with pid \"\(pid)\"\nexiting...")
                throw SniperError.TargetNotFound
            }
            filtered.forEach(self.terminate)
        } else if let bundleId = bundleId {
            let apps = NSRunningApplication.runningApplicationsWithBundleIdentifier(bundleId)
            guard !apps.isEmpty else {
                print("Couldn't find any processes named \"\(bundleId)\"\nexiting...")
                throw SniperError.TargetNotFound
            }
            apps.forEach(self.terminate)
        }
    }
}

CLI.registerCommand(Target())
CLI.registerCommand(Shot())
let result = CLI.go()
exit(result)



