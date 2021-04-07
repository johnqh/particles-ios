//
//  MapObjectPresenterView.swift
//  MapParticles
//
//  Created by Qiang Huang on 8/29/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import ParticlesKit
import PlatformParticles

public enum PintipPosition: String {
    case bottom
    case top
    case left
    case right
    case center
    case bottomLeft
    case bottomRight
    case topLeft
    case topRight
}

@objc open class MapObjectPresenterView: ObjectPresenterView {
    @IBInspectable var pinTipPositionString: String?

    public var pinTipPosition: PintipPosition {
        if let pinTipPositionString = pinTipPositionString {
            return PintipPosition(rawValue: pinTipPositionString) ?? .bottom
        }
        return .bottom
    }
}
