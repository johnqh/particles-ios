//
//  CompositeTracking.swift
//  TrackingKit
//
//  Created by Qiang Huang on 10/9/18.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import Foundation

public class CompositeTracking: NSObject & TrackingProtocol {
    public var userInfo: [String: String]? {
        get {
            return trackings.first?.userInfo
        }
        set {
            for tracking in trackings {
                tracking.userInfo = newValue
            }
        }
    }

    public var excluded: Bool = false {
        didSet {
            if excluded != oldValue {
                for tracking in trackings {
                    tracking.excluded = excluded
                }
            }
        }
    }

    private var trackings: [TrackingProtocol] = [TrackingProtocol]()

    public func add(_ tracking: TrackingProtocol?) {
        if let aTracking = tracking {
            aTracking.excluded = excluded
            trackings.append(aTracking)
        }
    }

    public func path(_ path: String?, data: [String: Any]?) {
        for tracking: TrackingProtocol in trackings {
            tracking.path(path, data: data)
        }
    }

    public func path(_ path: String?, action: String?, data: [String: Any]?) {
        for tracking: TrackingProtocol in trackings {
            tracking.path(path, action: action, data: data)
        }
    }

    open func log(event: String, data: [String: Any]?) {
        for tracking: TrackingProtocol in trackings {
            tracking.log(event: event, data: data)
        }
    }
}
