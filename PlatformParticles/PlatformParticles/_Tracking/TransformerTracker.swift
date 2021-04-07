//
//  TransformerTracker.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 1/21/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import ParticlesKit
import Utilities

open class TransformerTracker: NSObject & TrackingProtocol {
    open var userInfo: [String: String]?

    public var excluded: Bool = false

    private var entity: DictionaryEntity?

    override public init() {
        super.init()

        if let destinations = (JsonLoader.load(bundle: Bundle.main, fileName: "events.json") ?? JsonLoader.load(bundles: Bundle.particles, fileName: "events.json")) as? [String: Any] {
            entity = DictionaryEntity()
            entity?.parse(dictionary: destinations)
        }
    }

    public func path(_ path: String?, data: [String: Any]?) {
        if !excluded {
            if let path = path?.replacingOccurrences(of: "/", with: "_") {
                let event = (entity?.data?[path] as? String) ?? path
                log(event: event, data: data)
            }
        }
    }

    public func path(_ path: String?, action: String?, data: [String: Any]?) {
        if !excluded {
            if let path = path, let action = action {
                self.path("\(path)_\(action)", data: data)
            }
        }
    }

    open func log(event: String, data: [String: Any]?) {
    }
}
