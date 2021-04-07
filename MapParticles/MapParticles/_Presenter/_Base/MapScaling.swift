//
//  MapScaling.swift
//  MapParticles
//
//  Created by Qiang Huang on 2/24/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import UIKit

@objc public class MapScaling: NSObject {
    @objc public dynamic var scale: NSNumber?
}

@objc public protocol MapScalingObserverProtocol {
    var scaling: MapScaling? { get set }
}
