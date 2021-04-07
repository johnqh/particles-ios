//
//  AnalyticsProtocol.swift
//  TrackingKit
//
//  Created by Qiang Huang on 10/8/18.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import Foundation

public protocol TrackingProtocol: NSObjectProtocol {
    var userInfo: [String: String]? { get set }
    var excluded: Bool { get set }
    func path(_ path: String?, data: [String: Any]?)
    func path(_ path: String?, action: String?, data: [String: Any]?)
    func log(event: String, data: [String: Any]?)
}

public class Tracking {
    public static var shared: TrackingProtocol?
}
