//
//  FeatureService.swift
//  Utilities
//
//  Created by Qiang Huang on 12/19/18.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import Foundation

@objc public protocol FeatureFlagsProtocol: NSObjectProtocol {
    var featureFlags: [String: Any]? { get }

    func activate(completion: @escaping () -> Void)
    func flag(feature: String?) -> Any?
}

public class FeatureService {
    public static var shared: FeatureFlagsProtocol?
}
