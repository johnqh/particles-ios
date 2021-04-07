//
//  DefaultExtensionDelegate.swift
//  PlatformParticlesAppleWatch
//
//  Created by Qiang Huang on 12/8/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import ParticlesKit
import PlatformRouting
import RoutingKit
import Utilities

open class DefaultExtensionDelegate: RoutingExtensionDelegate {
    open override func applicationDidFinishLaunching() {
        inject()

        super.applicationDidFinishLaunching()
    }

    open func inject() {
        Injection.shared = ParticlesInjection()
    }
}
