//
//  MapViewProtocols.swift
//  MapParticles
//
//  Created by Qiang Huang on 4/30/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import MapKit
import ParticlesKit
import Utilities

@objc public enum MapMode: Int {
    case standard
    case satellite
    case standardFlyover
    case satelliteFlyover
}

@objc public enum FollowingMode: Int {
    case none
    case follow
    case followWithHeading
}

public protocol OverlayProtocol: NSObjectProtocol {
    var overlayBoundingMapRect: MKMapRect { get }
}

public protocol MapViewProtocol: NSObjectProtocol {
    var showsUserLocation: Bool { get set }
    var mapMode: MapMode { get set }
    var followingMode: FollowingMode { get set }
    var mapShowUserLocation: Bool { get set }
    var region: MKCoordinateRegion { get set }
    var mapAnnotations: [AnnotationProtocol] { get }
    var mapOverlays: [OverlayProtocol] { get }

    func userLocation() -> AnnotationProtocol?
    func annotations(includesUser: Bool) -> [AnnotationProtocol]?
    func padding(for area: MapArea?, span: Double, edgePadding: UIEdgeInsets) -> UIEdgeInsets?
    func view(area: MapArea?, zoomPadding: UIEdgeInsets, animated: Bool)
    func zoom(to location: CLLocationCoordinate2D, zoomPadding: UIEdgeInsets, scale: Double, animated: Bool)
    func zoom(to location: CLLocationCoordinate2D, zoomPadding: UIEdgeInsets, zoomLevel: UInt, animated: Bool)
    func move(to location: CLLocationCoordinate2D, zoomPadding: UIEdgeInsets, forced: Bool, animated: Bool)
    func move(to annotation: AnnotationProtocol?, zoomPadding: UIEdgeInsets, forced: Bool, animated: Bool)
    func moveIntoView(coordinate: CLLocationCoordinate2D, bottom: UIView, animated: Bool)

    func setRegion(_ region: MKCoordinateRegion, animated: Bool)
    func add(annotation: AnnotationProtocol)
    func add(annotations: [AnnotationProtocol])
    func remove(annotation: AnnotationProtocol)
    func remove(annotations: [AnnotationProtocol])
    func select(annotation: AnnotationProtocol, animated: Bool)
    func deselect(annotation: AnnotationProtocol, animated: Bool)

    func coordinate(point: CGPoint, from: UIView?) -> CLLocationCoordinate2D
}

public extension MapViewProtocol {
    func area(annotations: [AnnotationProtocol]?) -> MapArea? {
        if let annotations = annotations, annotations.count > 1 {
            let points = annotations.map { (annotation) -> MapPoint in
                MapPoint(latitude: annotation.annotationCoordinate.latitude, longitude: annotation.annotationCoordinate.longitude)
            }
            return MapArea(points: points)
        }
        return nil
    }
}

public protocol PolylineProtocol: OverlayProtocol {
}

public protocol PolygonProtocol: OverlayProtocol {
}

public protocol CircleProtocol: OverlayProtocol {
    var circleCoordinate: CLLocationCoordinate2D { get }
    var circleRadius: CLLocationDistance { get }
}

@objc public protocol PolylineObjectProtocol: ModelObjectProtocol {
    @objc var color: UIColor? { get }
    @objc var lineWidth: Double { get }
    @objc var polyline: [CLLocationCoordinate2D]? { get }
    @objc var valid: Bool { get }
}

@objc public protocol PolygonObjectProtocol: ModelObjectProtocol {
    @objc var color: UIColor? { get }
    @objc var lineWidth: Double { get }
    @objc var alpha: Double { get }
    @objc var polygon: [CLLocationCoordinate2D]? { get }
    @objc var valid: Bool { get }
}

@objc public protocol CircleObjectProtocol: ModelObjectProtocol {
    @objc var center: [CLLocationCoordinate2D]? { get }
    @objc var radius: Double { get }
    @objc var lineWidth: Double { get }
    @objc var color: UIColor? { get }
    @objc var alpha: Double { get }
    @objc var text: String? { get }
    @objc var textColor: UIColor? { get }
    @objc var valid: Bool { get }
}

@objc public protocol PolylineMapViewProtocol: NSObjectProtocol {
    func removePolylines()
    func add(polylines: [PolylineObjectProtocol]?)
}

@objc public protocol PolygonMapViewProtocol: NSObjectProtocol {
    func removePolygons()
    func add(polygons: [PolygonObjectProtocol]?)
}

@objc public protocol CircleMapViewProtocol: NSObjectProtocol {
    func removeCircles()
    func add(circles: [CircleObjectProtocol]?)
}

@objc public protocol DraggableAnnotationProtocol: NSObjectProtocol {
    var draggable: Bool { get }

    func set(latitude: Double, longitude: Double)
}

@objc public protocol MapAnnotationPresenterProtocol: NSObjectProtocol {
    var showCallout: Bool { get }
    func accessoryButton() -> UIButton?
}
