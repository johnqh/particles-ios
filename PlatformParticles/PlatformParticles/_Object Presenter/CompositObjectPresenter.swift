//
//  CompositObjectPresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 10/23/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import ParticlesKit
import UIToolkits

@objc open class CompositObjectPresenter: ObjectPresenter {
    @IBOutlet var childPresenters: [ObjectPresenter]? {
        didSet {
            modelChanged()
        }
    }

    @IBOutlet var view: UIView?

    override open var model: ModelObjectProtocol? {
        didSet {
            if model !== oldValue {
                modelChanged()
            }
        }
    }

    private func modelChanged() {
        if let childPresenters = childPresenters {
            for childPresenter in childPresenters {
                childPresenter.model = model
            }
        }
    }
}
