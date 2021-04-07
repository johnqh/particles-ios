//
//  DebugEnableAction.swift
//  PlatformRouting
//
//  Created by Qiang Huang on 7/21/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import RoutingKit
import Utilities

open class DebugEnableAction: NSObject, NavigableProtocol {
    open func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        switch request?.path {
        case "/action/debug/enable":
            UserDefaults.standard.set(true, forKey: "debug.enabled")
            completion?(nil, true)

        default:
            completion?(nil, false)
        }
    }
}
