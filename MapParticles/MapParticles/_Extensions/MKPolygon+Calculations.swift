//
//  MKPolygon+Calculations.swift
//  MapParticles
//
//  Created by Qiang Huang on 1/15/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import MapKit

public extension MKPolygonRenderer {
    func contains(coordiante: CLLocationCoordinate2D) -> Bool {
        let point = MKMapPoint(coordiante)
        return contains(point: point)
    }

    func contains(point: MKMapPoint) -> Bool {
        let viewPoint = self.point(for: point)
        return path.contains(viewPoint)
    }
}

public extension MKPolygon {
    func contains(_ coordiante: CLLocationCoordinate2D) -> Bool {
        let point = MKMapPoint(coordiante)
        return contains(point: point)
    }

    func contains(point: MKMapPoint) -> Bool {
        let renderer = MKPolygonRenderer(polygon: self)
        return renderer.contains(point: point)
    }
}
