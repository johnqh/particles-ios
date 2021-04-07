//
//  MKMapView+Circle.swift
//  MapParticles
//
//  Created by Qiang Huang on 2/2/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import MapKit
import ParticlesKit

extension MKMapView: CircleMapViewProtocol {
    public func removeCircles() {
        let circles = overlays.compactMap({ (overlay) -> MKOverlay? in
            if overlay is MKCircle {
                return overlay
            }
            return nil
        })
        removeOverlays(circles)
    }

    public func add(circles: [CircleObjectProtocol]?) {
        if let mkCircles = circles?.compactMap({ (circle) -> ColoredCircle? in
            if let coordinate = circle.center?.first {
                let mkCircle = ColoredCircle(center: coordinate, radius: circle.radius)
                mkCircle.color = circle.color
                mkCircle.textColor = circle.textColor
                mkCircle.lineWidth = CGFloat(circle.lineWidth)
                mkCircle.alpha = CGFloat(circle.alpha)
                mkCircle.text = circle.text
                return mkCircle
            }
            return nil
        }) {
            addOverlays(mkCircles)
        }
    }
}
