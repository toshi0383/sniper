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
        version: "0.2.0",
    description: "the OSX app terminator"
)
/**
 attempt to execute throwable block

 - seealso: [Implementing printing versions of “try?” and “try!” — on steroids! in #swiftlang](http://ericasadun.com/2015/11/05/implementing-printing-versions-of-try-and-try-on-steroids-in-swiftlang/)
*/
func attempt<T>(block: () throws -> T) -> Optional<T> {
    do { return try block() }
    catch { print(error); return nil }
}
enum SniperError: ErrorType {
    case InvalidArgument, TargetNotFound
}
class Target: CommandType {
    let commandName = "target"
    let commandShortDescription = "List all running apps's info."
    let commandSignature = "[<keyword>]"

    func execute(arguments: CommandArguments) throws  {
        let keyword = arguments.optionalArgument("keyword")
        let apps = try getApps(keyword)
        print("\(apps.count) app\(apps.count == 1 ? "" : "s") found.")
        for app in apps {
            print("\(app.bundleIdentifier ?? UnknownBundleID): \(app.processIdentifier)")
        }
    }
    /**
     get all target apps
     Result is filtered by given keyword

     - throws:
        - SniperError.InvalidArgument: if specified keyword contains invalid regex
    */
    func getApps(keyword:String? = nil) throws -> [NSRunningApplication] {
        let apps = NSWorkspace.sharedWorkspace().runningApplications
        switch keyword {
        case .None:
            return apps
        case .Some(let keyword):
            guard let regex = attempt({
                try NSRegularExpression(pattern: "\(keyword)", options: .CaseInsensitive)
            }) else {
                throw SniperError.InvalidArgument
            }
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

    /**
     - throws:
        - SniperError.InvalidArgument: if specified pid was invalid
        - SniperError.TargetNotFound: if no process was found
    */
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
                print("No such process: \"\(pid)\"")
                throw SniperError.TargetNotFound
            }
            filtered.forEach(self.terminate)
        } else if let bundleId = bundleId {
            let apps = NSRunningApplication.runningApplicationsWithBundleIdentifier(bundleId)
            guard !apps.isEmpty else {
                print("No such process: \"\(bundleId)\"")
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



