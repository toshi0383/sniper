//
//  SwiftExtensions.swift
//  sniper
//
//  Created by toshi0383 on 11/7/15.
//  Copyright © 2015 toshi0383. All rights reserved.
//

/**
 attempt to execute throwable block

 - seealso: [Implementing printing versions of “try?” and “try!” — on steroids! in #swiftlang](http://ericasadun.com/2015/11/05/implementing-printing-versions-of-try-and-try-on-steroids-in-swiftlang/)
*/
func attempt<T>(block: () throws -> T) -> Optional<T> {
    do { return try block() }
    catch { print(error); return nil }
}
