//
//  CompositeFeatureFlagsProvider.swift
//  Utilities
//
//  Created by Qiang Huang on 10/3/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import Foundation

public class CompositeFeatureFlagsProvider: NSObject & FeatureFlagsProtocol {
    public var featureFlags: [String: Any]? {
        let localFlags = local?.featureFlags
        let remoteFlags = remote?.featureFlags
        if let localFlags = localFlags {
            if let remoteFlags = remoteFlags {
                return remoteFlags.merging(localFlags) { (_, local) -> Any in
                    local
                }
            } else {
                return localFlags
            }
        } else {
            return remoteFlags
        }
    }

    public func activate(completion: @escaping () -> Void) {
        if let local = local {
            local.activate { [weak self] in
                if let remote = self?.remote {
                    remote.activate(completion: completion)
                } else {
                    completion()
                }
            }
        } else if let remote = remote {
            remote.activate(completion: completion)
        }
    }

    public func flag(feature: String?) -> Any? {
        if Installation.appStore {
            return remote?.flag(feature: feature)
        } else {
            if let localFlag = local?.flag(feature: feature) {
                return localFlag
            } else {
                return remote?.flag(feature: feature)
            }
        }
    }

    public var local: FeatureFlagsProtocol?
    public var remote: FeatureFlagsProtocol?
}
