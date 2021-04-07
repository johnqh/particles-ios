//
//  MKMapView+Polyline.swift
//  MapParticles
//
//  Created by Qiang Huang on 10/25/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import MapKit
import ParticlesKit

extension MKMapView: PolygonMapViewProtocol {
    public func removePolygons() {
        let polygons = overlays.compactMap({ (overlay) -> MKOverlay? in
            if overlay is MKPolygon {
                return overlay
            }
            return nil
        })
        removeOverlays(polygons)
    }

    public func add(polygons: [PolygonObjectProtocol]?) {
        if let mkPolygons = polygons?.compactMap({ (polygon) -> ColoredPolygon? in
            if let coordinates = polygon.polygon {
                let mkPolygon = ColoredPolygon(coordinates: coordinates, count: coordinates.count)
                mkPolygon.color = polygon.color
                mkPolygon.lineWidth = CGFloat(polygon.lineWidth)
                mkPolygon.alpha = CGFloat(polygon.alpha)
                return mkPolygon
            }
            return nil
        }) {
            addOverlays(mkPolygons)
        }
    }
}
