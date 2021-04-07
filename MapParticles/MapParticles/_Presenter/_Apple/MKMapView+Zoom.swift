//
//  MKMapView+Zoom.swift
//  MapParticles
//
//  Created by Qiang Huang on 12/5/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import MapKit
import ParticlesKit
import Utilities

public extension MKMapView {
    func showArea(_ area: MapArea?, edgePadding: UIEdgeInsets, animated: Bool) {
        if let area = area, let topLeft = area.topLeft, let bottomRight = area.bottomRight, let topLeftLatitude = topLeft.latitude, let topLeftLongitude = topLeft.longitude, let bottomRightLatitude = bottomRight.latitude, let bottomRightLongitude = bottomRight.longitude {
            let pointSize = MKMapSize(width: 0, height: 0)

            let point1 = MKMapPoint(CLLocationCoordinate2D(latitude: topLeftLatitude, longitude: topLeftLongitude))
            var mapRect = MKMapRect(origin: point1, size: pointSize)

            let point2 = MKMapPoint(CLLocationCoordinate2D(latitude: bottomRightLatitude, longitude: bottomRightLongitude))
            let point2Rect = MKMapRect(origin: point2, size: pointSize)
            mapRect = mapRect.union(point2Rect)
            setVisibleMapRect(mapRect, edgePadding: edgePadding, animated: animated)
        }
    }
}
