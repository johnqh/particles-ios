//
//  ParticlesPlatformInjection.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 12/26/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import ParticlesKit
import PlatformRouting
import Utilities
import UIToolkits

open class ParticlesPlatformInjection: ParticlesInjection {
    open override func injectAppStart(completion: @escaping () -> Void) {
        super.injectAppStart {[weak self] in
            self?.injectUI()
            completion()
        }
    }
    
    open func injectUI() {
        Console.shared.log("injectUI")
        RoutingTabBarController.parserOverwrite = Parser.featureFlagged
        PrompterFactory.shared = UIKitPrompterFactory()
    }
}
