//
//  DebugTracking.swift
//  ParticlesKit
//
//  Created by John Huang on 12/20/18.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import Foundation

public class DebugTracking: NSObject & TrackingProtocol {
    public var userInfo: [String: String]?

    public var excluded: Bool = false

    public func path(_ path: String?, data: [String: Any]?) {
        if let path = path {
            if excluded {
                Console.shared.log("Excluded Path:\(path)", data ?? "")
            } else {
                Console.shared.log("Path:\(path)", data ?? "")
            }
        }
    }

    public func path(_ path: String?, action: String?, data: [String: Any]?) {
        if let path = path, let action = action {
            if excluded {
                Console.shared.log("Excluded Path:\(path) Action:\(action)", data ?? "")
            } else {
                Console.shared.log("Path:\(path) Action:\(action)", data ?? "")
            }
        }
    }

    open func log(event: String, data: [String: Any]?) {
        Console.shared.log("event:\(event), ", data ?? "")
    }
}
