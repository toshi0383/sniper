//
//  main.swift
//  sniper
//
//  Created by toshi0383 on 11/6/15.
//  Copyright © 2015 toshi0383. All rights reserved.
//

import Darwin.C

CLI.setup(
           name: "sniper",
        version: "0.2.0",
    description: "the OSX app terminator"
)
CLI.registerCommand(Target())
CLI.registerCommand(Shoot())
let result = CLI.go()
exit(result)
