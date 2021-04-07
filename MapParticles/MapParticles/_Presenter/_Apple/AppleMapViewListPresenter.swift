//
//  AppleMapViewListPresenter.swift
//  PresenterLib
//
//  Created by John Huang on 10/12/18.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import Differ
import MapKit
import MKMapView_ZoomLevel
import ParticlesKit
import PlatformParticles
import RoutingKit
import UIToolkits
import Utilities

open class AppleMapViewListPresenter: MapViewListPresenter, MKMapViewDelegate {
    @IBInspectable var customView: Bool = false

    open var scaling: MapScaling?

    override open var region: Region? {
        didSet {
            if region !== oldValue {
                if let zoom = mkMapView?.zoomLevel() {
                    scaling?.scale = NSNumber(floatLiteral: Double(zoom))
                } else {
                    scaling?.scale = nil
                }
            }
        }
    }

//    open override var coordinate: CLLocationCoordinate2D? {
//        didSet {
//            (mapView as? MKMapView)?.showsUserLocation = (coordinate != nil)
//        }
//    }

    @objc override open dynamic var mapView: UIView? {
        didSet {
            if mapView !== oldValue {
                (oldValue as? MKMapView)?.delegate = nil
                mkMapView?.delegate = self
                if let region = mkMapView?.region {
                    self.region = Region(region: region)
                }
            }
        }
    }

    public var mkMapView: MKMapView? {
        return mapView as? MKMapView
    }

    /*
     open override func change(to new: [ModelObjectProtocol]) {
         if changed(new: new) {
             let oldSet = Set(current! as! [NSObject])
             let newSet = Set(new as! [NSObject])

             let removed: [MKAnnotation] = current!.filter { (element) -> Bool in
                 if let annotation = element as? MKAnnotation {
                     if !annotation.coordinate.isEqual(kCLLocationCoordinate2DInvalid) {
                         return !newSet.contains(element as! NSObject)
                     }
                 }
                 return false
             } as! [MKAnnotation]
             let inserted: [MKAnnotation] = new.filter { (element) -> Bool in
                 if let annotation = element as? MKAnnotation {
                     if !annotation.coordinate.isEqual(kCLLocationCoordinate2DInvalid) {
                         return !oldSet.contains(element as! NSObject)
                     }
                 }
                 return false
             } as! [MKAnnotation]
             mapView?.removeAnnotations(removed)
             mapView?.addAnnotations(inserted)
             current = new
         }
     }
     */

//
//    public func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
//        updating = true
//    }
//
//    public func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
//        updating = false
//    }

//    public func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
//        self.updating = true
//    }
//
//    public func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
//        self.updating = false
//    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        scaling = MapScaling()
    }

    override open func reallyUpdateLocation(animated: Bool) {
        super.reallyUpdateLocation(animated: animated)
        if let mkMapView = mkMapView {
            regionChanged(mapView: mkMapView)
        }
    }

    open func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        } else if customView {
            var xibFile: String?
            if annotation is (ModelObjectProtocol) {
                xibFile = xib(object: annotation as? (ModelObjectProtocol))
            }
            let identifier = xibFile ?? "marker"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if view != nil {
                view?.annotation = annotation
            } else {
                view = MapAnnotationObjectPresenterView(annotation: annotation, reuseIdentifier: identifier)
            }
            (view as? MapAnnotationObjectPresenterView)?.xib = xibFile
            (view as? MapAnnotationObjectPresenterView)?.scaling = scaling
            if let mapAnnotationPresenter = ((view as? MapAnnotationObjectPresenterView)?.presenterView as? ObjectPresenterView)?.presenter as? MapAnnotationPresenterProtocol {
                view?.canShowCallout = mapAnnotationPresenter.showCallout
                view?.rightCalloutAccessoryView = mapAnnotationPresenter.accessoryButton() ?? UIButton(type: .detailDisclosure)
            } else {
                view?.canShowCallout = !directInteraction
                view?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
            setCenterOffset(view: view)
            return view
        } else {
            let identifier = "marker"
            var view: MKMarkerAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKMarkerAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKMarkerObjectPresenterView(annotation: annotation, reuseIdentifier: identifier)
                view.animatesWhenAdded = true
            }
            view.canShowCallout = !directInteraction
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return view
        }
    }

    open func setCenterOffset(view: MKAnnotationView?) {
        if let view = view {
            var pinTipPosition: PintipPosition = .bottom
            if let objectView = (view as? MapAnnotationObjectPresenterView)?.presenterView as? MapObjectPresenterView {
                pinTipPosition = objectView.pinTipPosition
            }
            switch pinTipPosition {
            case .center:
                view.centerOffset = CGPoint(x: 0, y: 0)
            case .top:
                view.centerOffset = CGPoint(x: 0, y: view.frame.size.height / 2)
            case .left:
                view.centerOffset = CGPoint(x: view.frame.size.width / 2, y: 0)
            case .right:
                view.centerOffset = CGPoint(x: -view.frame.size.width / 2, y: 0)
            case .topLeft:
                view.centerOffset = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height / 2)
            case .topRight:
                view.centerOffset = CGPoint(x: -view.frame.size.width / 2, y: view.frame.size.height / 2)
            case .bottomLeft:
                view.centerOffset = CGPoint(x: view.frame.size.width / 2, y: -view.frame.size.height / 2)
            case .bottomRight:
                view.centerOffset = CGPoint(x: -view.frame.size.width / 2, y: -view.frame.size.height / 2)

            case .bottom:
                fallthrough
            default:
                view.centerOffset = CGPoint(x: 0, y: -view.frame.size.height / 2)
            }
        }
    }

    #if _iOS
        open func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                          calloutAccessoryControlTapped control: UIControl) {
            select(object: view.annotation as? (ModelObjectProtocol))
        }
    #endif

    open func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if locationMode != .follow {
            let handler = movingDebouncer.debounce()
            handler?.run({ [weak self] in
                self?.regionChanged(mapView: mapView)
            }, delay: animated ? 2.5 : 0.5)
        }
    }

    open func regionChanged(mapView: MKMapView) {
        if maxZoomLevel != 0, mapView.zoomLevel() < maxZoomLevel {
            mapView.setCenter(mapView.centerCoordinate, zoomLevel: maxZoomLevel, animated: true)
        } else {
            region = Region(region: mapView.region)
        }
    }

    open func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if !selecting {
            if directInteraction {
                _ = selectionHandler?.select((view as? ObjectPresenterProtocol)?.model)
                if (selectionHandler as? PersistSelectionHandlerProtocol)?.multipleSelection ?? false {
                    mapView.deselectAnnotation(view.annotation, animated: true)
                }
            }
        }
    }

    open func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if !selecting {
            if directInteraction {
                if (selectionHandler as? PersistSelectionHandlerProtocol)?.multipleSelection ?? false {
                } else {
                    selectionHandler?.deselect(view.annotation as? ModelObjectProtocol)
                }
            }
        }
    }

    override open func moveIntoView(coordinate: CLLocationCoordinate2D?, bottom: UIView?, animated: Bool = true) {
        if let bottom = bottom, let coordinate = coordinate {
            super.moveIntoView(coordinate: coordinate, bottom: bottom, animated: animated)
        } else {
            region = Region(region: mkMapView?.region)
        }
    }

    open func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? ColoredPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = polyline.color ?? UIColor.black
            lineView.lineWidth = polyline.lineWidth
            lineView.lineJoin = .round
            lineView.lineCap = .round
            return lineView
        } else if let polygon = overlay as? ColoredPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.strokeColor = polygon.color ?? UIColor.black
            polygonView.fillColor = polygonView.strokeColor?.withAlphaComponent(polygon.alpha)
            polygonView.lineWidth = polygon.lineWidth
            return polygonView
        } else if let circle = overlay as? ColoredCircle {
            let circleView = AppleMapViewCircleRenderer(circle: circle)
            circleView.strokeColor = (mapMode == .standard) ? (circle.color ?? UIColor.blue) : UIColor.white
            circleView.fillColor = circleView.strokeColor?.withAlphaComponent(circle.alpha)
            circleView.textColor = (mapMode == .standard) ? (circle.textColor ?? UIColor.blue) : UIColor.white
            circleView.lineWidth = 1
            return circleView
        }
        return MKOverlayRenderer()
    }

    open func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let object = view.annotation as? RoutingOriginatorProtocol {
            Router.shared?.navigate(to: object, animated: true, completion: nil)
        }
    }

    override open func view(area: MapArea, edgePadding: UIEdgeInsets, animated: Bool) {
        mkMapView?.showArea(area, edgePadding: edgePadding, animated: animated)
    }

    private var selecting: Bool = false
    override open func changed(selected: [ModelObjectProtocol]?) {
        if let mapView = mkMapView, !selecting {
            selecting = true
            let selectedAnnotations = mapView.selectedAnnotations
            for annotation in selectedAnnotations {
                if !(selected?.contains(where: { (item) -> Bool in
                    item === annotation
                }) ?? false) {
                    mapView.deselectAnnotation(annotation, animated: true)
                }
            }
            if let selected = selected {
                for object in selected {
                    if let annotation = object as? MKAnnotation {
                        if !selectedAnnotations.contains(where: { (item) -> Bool in
                            item === annotation
                        }) {
                            mapView.selectAnnotation(annotation, animated: true)
                        }
                    }
                }
            }
            selecting = false
        }
    }
}

extension AppleMapViewListPresenter {
    open func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        switch newState {
        case .starting:
            draggingPin = true
            view.dragState = .dragging

        case .none:
            break

        case .canceling:
            fallthrough
        case .ending:
            draggingPin = false
            view.dragState = .none

        default:
            draggingPin = true
        }
    }
}
