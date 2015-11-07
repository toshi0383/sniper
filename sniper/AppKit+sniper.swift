//
//  AppKit+sniper.swift
//  sniper
//
//  Created by toshi0383 on 11/7/15.
//  Copyright © 2015 toshi0383. All rights reserved.
//

import AppKit
extension NSRunningApplication {
    class func runningApplicationsWithProcessIdentifier(pid:Int) -> [NSRunningApplication] {
        let apps = NSWorkspace.sharedWorkspace().runningApplications
        return apps.filter {
            Int($0.processIdentifier) == pid
        }
    }
}
