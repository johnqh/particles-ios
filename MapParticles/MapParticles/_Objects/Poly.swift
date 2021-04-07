//
//  Poly.swift
//  MapParticles
//
//  Created by Qiang Huang on 10/25/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import MapKit

public class PolylineObject: NSObject, PolylineObjectProtocol {
    @objc public var color: UIColor?
    @objc public var lineWidth: Double = 2.0
    @objc public var polyline: [CLLocationCoordinate2D]?
    @objc public var valid: Bool = true
}

public class ColoredPolyline: MKPolyline {
    public var color: UIColor?
    public var lineWidth: CGFloat = 2.0
}

public class ColoredPolygon: MKPolygon {
    public var color: UIColor?
    public var lineWidth: CGFloat = 2.0
    public var alpha: CGFloat = 0.1
}

public class ColoredCircle: MKCircle {
    public var color: UIColor?
    public var lineWidth: CGFloat = 1.0
    public var alpha: CGFloat = 0.1
    public var text: String?
    public var textColor: UIColor?
}
