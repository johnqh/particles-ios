//
//  OCAnnotation+Particles.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 8/16/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import OCMapView
import ParticlesKit

extension OCAnnotation: ModelObjectProtocol {
}

extension OCAnnotation: ClusteredModelObjectProtocol {
    public var cluster: [ModelObjectProtocol]? {
        return annotationsInCluster()?.compactMap({ (annotation) -> ModelObjectProtocol? in
            annotation as? ModelObjectProtocol
        })
    }
}
