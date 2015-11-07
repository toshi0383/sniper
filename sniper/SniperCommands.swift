//
//  Command.swift
//  sniper
//
//  Created by toshi0383 on 11/7/15.
//  Copyright © 2015 toshi0383. All rights reserved.
//

import AppKit
let UnknownBundleID = "<unknown bundle ID>"

enum SniperError: ErrorType {
    case InvalidArgument, TargetNotFound, UnknownError
}

class Target: CommandType {
    var commandName:String {
        return "target"
    }

    var commandShortDescription:String {
        return "List all running apps's info."
    }

    var commandSignature:String {
        return "[<keyword>]"
    }

    func execute(arguments: CommandArguments) throws  {
        let keyword = arguments.optionalArgument("keyword")
        let apps = try getApps(keyword)
        print("\(apps.count) app\(apps.count == 1 ? "" : "s") found.")
        for app in apps {
            print("\(app.bundleIdentifier ?? UnknownBundleID): \(app.processIdentifier)")
        }
    }
}

/// private
extension Target {

    /**
     get all target apps
     Result is filtered by given keyword

     - parameter keyword: keyword string
     - throws:
        - SniperError.InvalidArgument: if specified keyword contains invalid regex
     - returns: target apps filtered by given keyword
    */
    private func getApps(keyword:String? = nil) throws -> [NSRunningApplication] {
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


class Shoot {

    var pid:Int?

    var bundleId:String?

}

extension Shoot: OptionCommandType {

    var commandName:String {
        return "shoot"
    }

    var commandShortDescription:String {
        return "Terminate the specified running app. You need to pass the exact bundleID or PID."
    }

    var commandSignature:String {
        return ""
    }

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

    /**
     - throws:
        - SniperError.InvalidArgument: if specified pid was invalid
        - SniperError.TargetNotFound: if no process was found
    */
    func execute(arguments: CommandArguments) throws {
        switch (pid, bundleId) {
        case (_?, _?):
            print("Cannot specify both bundleID(-b) and PID(-p) at the same time.")
            throw SniperError.InvalidArgument

        case let (nil, bundleId?):
            do {

                try terminateApps(
                    NSRunningApplication.runningApplicationsWithBundleIdentifier(bundleId)
                )

            } catch SniperError.TargetNotFound {
                print("No such process: \"\(bundleId)\"")
                throw SniperError.TargetNotFound

            }

        case let (pid?, nil):
            do {

                try terminateApps(
                    NSRunningApplication.runningApplicationsWithProcessIdentifier(pid)
                )

            } catch SniperError.TargetNotFound {
                print("No such process: \"\(pid)\"")
                throw SniperError.TargetNotFound

            }

        case (nil, nil):
            print("No target specified.")
            throw SniperError.InvalidArgument

        }
    }
}

/// private
extension Shoot {
    private func terminate(app:NSRunningApplication) {
        print("Terminating \(app.bundleIdentifier ?? UnknownBundleID): \(app.processIdentifier) ...")
        app.terminate()
    }

    private func terminateApps(@autoclosure getTargetBlock:()->[NSRunningApplication]) throws {
        let apps = getTargetBlock()
        guard !apps.isEmpty else {
            throw SniperError.TargetNotFound
        }
        apps.forEach(self.terminate)
    }
}
