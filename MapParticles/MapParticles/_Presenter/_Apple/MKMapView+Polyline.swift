//
//  MKMapView+Polyline.swift
//  MapParticles
//
//  Created by Qiang Huang on 10/25/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import MapKit
import ParticlesKit

extension MKMapView: PolylineMapViewProtocol {
    public func removePolylines() {
        let polylines = overlays.compactMap({ (overlay) -> MKOverlay? in
            if overlay is MKPolyline {
                return overlay
            }
            return nil
        })
        removeOverlays(polylines)
    }

    public func add(polylines: [PolylineObjectProtocol]?) {
        if let mkPolylines = polylines?.compactMap({ (polyline) -> ColoredPolyline? in
            if let coordinates = polyline.polyline {
                let mkPolyline = ColoredPolyline(coordinates: coordinates, count: coordinates.count)
                mkPolyline.color = polyline.color
                mkPolyline.lineWidth = CGFloat(polyline.lineWidth)
                return mkPolyline
            }
            return nil
        }) {
            addOverlays(mkPolylines)
        }
    }
}
