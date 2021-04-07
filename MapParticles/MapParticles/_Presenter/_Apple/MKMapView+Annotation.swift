//
//  MKMapView+Annotation.swift
//  MapParticles
//
//  Created by Qiang Huang on 4/30/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import MapKit
import ParticlesKit
import Utilities

extension MKMapView: MapViewProtocol {
    public var mapMode: MapMode {
        get {
            switch mapType {
            case .standard:
                return .standard

            case .satellite:
                return .satellite

            case .hybridFlyover:
                return .standardFlyover

            case .satelliteFlyover:
                return .satelliteFlyover

            default:
                return .standard
            }
        }
        set {
            switch newValue {
            case .standard:
                mapType = .standard

            case .satellite:
                mapType = .satellite

            case .standardFlyover:
                mapType = .standard

            case .satelliteFlyover:
                mapType = .satelliteFlyover
            }
        }
    }

    public var followingMode: FollowingMode {
        get {
            switch userTrackingMode {
            case .none:
                return .none

            case .follow:
                return .follow

            case .followWithHeading:
                return .followWithHeading

            @unknown default:
                return .none
            }
        }
        set {
            switch newValue {
            case .none:
                if userTrackingMode != .none {
                    setUserTrackingMode(.none, animated: true)
                }

            case .follow:
                if userTrackingMode != .none {
                    setUserTrackingMode(.none, animated: true)
                }

            case .followWithHeading:
                if userTrackingMode != .followWithHeading {
                    setUserTrackingMode(.followWithHeading, animated: true)
                }
            }
        }
    }

    public var mapShowUserLocation: Bool {
        get {
            return showsUserLocation
        }
        set {
            willChangeValue(forKey: "mapShowUserLocation")
            showsUserLocation = newValue
            didChangeValue(forKey: "mapShowUserLocation")
        }
    }

    public var mapAnnotations: [AnnotationProtocol] {
        return annotations.compactMap { (annotation) -> AnnotationProtocol? in
            annotation as? AnnotationProtocol
        }
    }

    public func add(annotation: AnnotationProtocol) {
        if let annotation = annotation as? MKAnnotation {
            addAnnotation(annotation)
        }
    }

    public func add(annotations: [AnnotationProtocol]) {
        addAnnotations(annotations.compactMap({ (annotation) -> MKAnnotation? in
            annotation as? MKAnnotation
        }))
    }

    public func remove(annotation: AnnotationProtocol) {
        if let annotation = annotation as? MKAnnotation {
            removeAnnotation(annotation)
        }
    }

    public func remove(annotations: [AnnotationProtocol]) {
        removeAnnotations(annotations.compactMap({ (annotation) -> MKAnnotation? in
            annotation as? MKAnnotation
        }))
    }

    public func select(annotation: AnnotationProtocol, animated: Bool) {
        if let annotation = annotation as? MKAnnotation {
            selectAnnotation(annotation, animated: animated)
        }
    }

    public func deselect(annotation: AnnotationProtocol, animated: Bool) {
        if let annotation = annotation as? MKAnnotation {
            deselectAnnotation(annotation, animated: animated)
        }
    }

    public var mapOverlays: [OverlayProtocol] {
        return overlays.compactMap { (overlay) -> OverlayProtocol? in
            overlay as? OverlayProtocol
        }
    }

    public func userLocation() -> AnnotationProtocol? {
        if CLLocationCoordinate2DIsValid(userLocation.coordinate) {
            return userLocation
        }
        return nil
    }

    public func annotations(includesUser: Bool) -> [AnnotationProtocol]? {
        return annotations.compactMap { (annotation) -> AnnotationProtocol? in
            if let object = annotation as? AnnotationProtocol {
                if object is MKUserLocation {
                    return includesUser ? object : nil
                } else {
                    return object
                }
            }
            return nil
        }
    }

    public func padding(for area: MapArea?, span: Double, edgePadding: UIEdgeInsets) -> UIEdgeInsets? {
        if let distance = area?.longitudeDistance(), distance > 0.0 {
            if distance > span {
                return edgePadding
            } else {
                let width = frame.width
                let contentWidth = CGFloat(distance) * width / CGFloat(span)
                let delta = (width - contentWidth) / 2.0
                if delta > edgePadding.left {
                    return UIEdgeInsets(top: edgePadding.top, left: delta, bottom: edgePadding.bottom, right: delta)
                } else {
                    return edgePadding
                }
            }
        } else if let distance = area?.latitudeDistance(), distance > 0.0 {
            if distance > span {
                return edgePadding
            } else {
                let height = frame.height
                let contentHeight = CGFloat(distance) * height / CGFloat(span)
                let delta = (height - contentHeight) / 2.0
                if delta > edgePadding.left {
                    return UIEdgeInsets(top: delta, left: edgePadding.left, bottom: delta, right: edgePadding.right)
                } else {
                    return edgePadding
                }
            }
        }
        return nil
    }

    public func view(area: MapArea?, zoomPadding: UIEdgeInsets, animated: Bool) {
        showArea(area, edgePadding: zoomPadding, animated: animated)
    }

    public func zoom(to location: CLLocationCoordinate2D, zoomPadding: UIEdgeInsets, scale: Double, animated: Bool) {
        var region = self.region
        region.center = location
        region.span.latitudeDelta = region.span.latitudeDelta * scale
        region.span.longitudeDelta = region.span.longitudeDelta * scale
        setRegion(region, animated: animated)
    }

    public func zoom(to location: CLLocationCoordinate2D, zoomPadding: UIEdgeInsets, zoomLevel: UInt, animated: Bool) {
        setCenter(location, zoomLevel: zoomLevel, animated: animated)
    }

    public func move(to location: CLLocationCoordinate2D, zoomPadding: UIEdgeInsets, forced: Bool, animated: Bool) {
        if CLLocationCoordinate2DIsValid(location), let visible = self.visible(region: region, zoomPadding: zoomPadding) {
            if !visible.contains(coordinate: location) || forced {
                let newVisible = MKCoordinateRegion(center: location, span: visible.span)
                if let newRegion = bounding(visible: newVisible, zoomPadding: zoomPadding) {
                    setRegion(newRegion, animated: animated)
                }
            }
        }
//        let span = region.span
//        let region2 = MKCoordinateRegion(center: location, span: span)
//        setRegion(region2, animated: true)
    }

    open func move(to annotation: AnnotationProtocol?, zoomPadding: UIEdgeInsets, forced: Bool, animated: Bool) {
        if let location = annotation?.annotationCoordinate {
            move(to: location, zoomPadding: zoomPadding, forced: forced, animated: animated)
        }
    }

    public func moveIntoView(coordinate: CLLocationCoordinate2D, bottom: UIView, animated: Bool) {
        let relativeRect = bottom.convert(bottom.bounds, to: self)
        let visibleRect = CGRect(x: 0, y: 0, width: frame.size.width, height: relativeRect.origin.y)
        let northWest = region.northWest
        let southEast = region.southEast
        let latitudeDelta = southEast.latitude - northWest.latitude
        if !latitudeDelta.isEqual(to: 0) {
            let latitudeCoordiateDelta = coordinate.latitude - northWest.latitude
            let latitudeCoordiatePercent = latitudeCoordiateDelta / latitudeDelta
            let latitudeVisiblePercent = Double(visibleRect.size.height * 0.9 / frame.height)
            if latitudeVisiblePercent.isLess(than: latitudeCoordiatePercent) {
                let distance = latitudeVisiblePercent.distance(to: latitudeCoordiatePercent)
                let latitudeSpan = region.span.latitudeDelta
                let center = region.center
                let newCenter = CLLocationCoordinate2DMake(center.latitude - latitudeSpan * distance, center.longitude)
                setRegion(MKCoordinateRegion(center: newCenter, span: region.span), animated: animated)
            }
        }
    }

    func visible(region: MKCoordinateRegion?, zoomPadding: UIEdgeInsets) -> MKCoordinateRegion? {
        if let region = region {
            let size = bounds.size
            let left = zoomPadding.left / size.width
            let right = zoomPadding.right / size.width
            let top = zoomPadding.top / size.height
            let bottom = zoomPadding.bottom / size.height

            let northWest = region.northWest
            let southEast = region.southEast

            let latitudeSpan = southEast.latitude - northWest.latitude
            let longitudeSpan = southEast.longitude - northWest.longitude

            let leftLongitude = northWest.longitude + longitudeSpan * Double(left)
            let rightLongitude = southEast.longitude - longitudeSpan * Double(right)
            let topLatitude = northWest.latitude + latitudeSpan * Double(top)
            let bottomLatitude = southEast.latitude - latitudeSpan * Double(bottom)
            let center = CLLocationCoordinate2D(latitude: (topLatitude + bottomLatitude) / 2.0, longitude: (leftLongitude + rightLongitude) / 2.0)
            let span = MKCoordinateSpan(latitudeDelta: fabs(bottomLatitude - topLatitude), longitudeDelta: fabs(rightLongitude - leftLongitude))
            return MKCoordinateRegion(center: center, span: span)
        }
        return nil
    }

    open func bounding(visible: MKCoordinateRegion?, zoomPadding: UIEdgeInsets) -> MKCoordinateRegion? {
        if let visible = visible {
            let size = bounds.size
            let left = zoomPadding.left / size.width
            let right = zoomPadding.right / size.width
            let top = zoomPadding.top / size.height
            let bottom = zoomPadding.bottom / size.height

            let northWest = visible.northWest
            let southEast = visible.southEast

            let latitudeSpan = (southEast.latitude - northWest.latitude) / Double(1.0 - top - bottom)
            let longitudeSpan = (southEast.longitude - northWest.longitude) / Double(1.0 - left - right)

            let leftLongitude = northWest.longitude - longitudeSpan * Double(left)
            let rightLongitude = southEast.longitude + longitudeSpan * Double(right)
            let topLatitude = northWest.latitude - latitudeSpan * Double(top)
            let bottomLatitude = southEast.latitude + latitudeSpan * Double(bottom)
            let center = CLLocationCoordinate2D(latitude: (topLatitude + bottomLatitude) / 2.0, longitude: (leftLongitude + rightLongitude) / 2.0)
            let span = MKCoordinateSpan(latitudeDelta: fabs(bottomLatitude - topLatitude), longitudeDelta: fabs(rightLongitude - leftLongitude))
            return MKCoordinateRegion(center: center, span: span)
        }
        return nil
    }

    open func coordinate(point: CGPoint, from: UIView?) -> CLLocationCoordinate2D {
        return convert(point, toCoordinateFrom: from)
    }
}
