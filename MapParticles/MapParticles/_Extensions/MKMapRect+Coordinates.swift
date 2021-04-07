//
//  MKMapRect+Coordinates.swift
//  MapParticles
//
//  Created by Qiang Huang on 2/7/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import MapKit

extension MKMapRect {
    public var northEast: MKMapPoint {
        return MKMapPoint(x: maxX, y: origin.y)
    }
    
    public var southWest: MKMapPoint {
        return MKMapPoint(x: origin.x, y: maxY)
    }
    
    public var region: MKCoordinateRegion {
        return MKCoordinateRegion(self)
    }
}
