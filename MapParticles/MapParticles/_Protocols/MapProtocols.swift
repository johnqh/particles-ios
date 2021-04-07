//
//  MapProtocols.swift
//  MapParticles
//
//  Created by Qiang Huang on 4/30/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import MapKit
import ParticlesKit

extension MKAnnotation where Self: AnnotationProtocol {
    public var annotationCoordinate: CLLocationCoordinate2D {
        return coordinate
    }

    public var annotationTitle: String? {
        return title ?? nil
    }

    public var annotationSubtitle: String? {
        return subtitle ?? nil
    }
}

extension MKUserLocation: AnnotationProtocol {
    public var inclusion: AnnotationInclusion {
        return .none
    }

    public var preferedContent: Bool {
        return false
    }
}

extension MKOverlay where Self: OverlayProtocol {
    public var overlayBoundingMapRect: MKMapRect {
        return boundingMapRect
    }
}

extension MKPolyline: PolylineProtocol {
}

extension MKPolygon: PolygonProtocol {
}

extension MKCircle: CircleProtocol {
    public var circleCoordinate: CLLocationCoordinate2D {
        return coordinate
    }

    public var circleRadius: CLLocationDistance {
        return radius
    }
}
