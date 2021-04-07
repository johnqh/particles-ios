//
//  DebugSettings.swift
//  Utilities
//
//  Created by Qiang Huang on 11/30/18.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import Foundation

public protocol DebugProtocol {
    var debug: [String: Any]? { get set }
}

public class DebugSettings {
    public static var shared: DebugProtocol?
}
