//
//  MapViewListPresenter.swift
//  PlatformParticles
//
//  Created by John Huang on 1/1/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import Differ
import MapKit
import ParticlesKit
import PlatformParticles
import RoutingKit
import UIToolkits
import Utilities

/*
 Mapview behavior
 Two kinds of maps
 1. Content refresh with map region. mainMap needs to be true
 2. Map goes with content. mainMap needs to be false
 */

/*
 Start with user or content mode

 */
@objc public enum LocationMode: Int {
    case unknown
    case free // Don't do anything automatic
    case envelope // Show both annotations and user location
    case content // Show annotations
    case user // zoom to user
    case follow // follow user
}

@objc public enum ViewMode: Int {
    case standard
    case satellite
}

public extension CLLocationCoordinate2D {
    func isEqual(_ coord: CLLocationCoordinate2D) -> Bool {
        return (fabs(latitude - coord.latitude) < .ulpOfOne) && (fabs(longitude - coord.longitude) < .ulpOfOne)
    }
}

@objc public class Region: NSObject {
    public var region: MKCoordinateRegion?
    public var area: MapArea? {
        if let region = region {
            let topLeft = MapPoint()
            topLeft.latitude = region.northWest.latitude
            topLeft.longitude = region.northWest.longitude
            let bottomRight = MapPoint()
            bottomRight.latitude = region.southEast.latitude
            bottomRight.longitude = region.southEast.longitude

            let area = MapArea()
            area.topLeft = topLeft
            area.bottomRight = bottomRight

            return area
        } else {
            return nil
        }
    }

    public init(region: MKCoordinateRegion?) {
        self.region = region
        super.init()
    }
}

@objc public class DrawPolygon: NSObject, PolygonObjectProtocol {
    public var valid: Bool = true
    public var color: UIColor? = ColorPalette.shared.color(keyed: "blue")
    public var lineWidth: Double = 2.0
    public var alpha: Double = 0.1
    public var polygon: [CLLocationCoordinate2D]?
}

open class MapViewListPresenter: XibListPresenter {
    private var locationModeDebouncer: Debouncer = Debouncer()
    @objc open dynamic var locationMode: LocationMode = .unknown {
        didSet {
            if locationMode != oldValue {
                updateMapMode()
                updateButtons()
                updateLocation(animated: false)
            }
        }
    }

    @objc open dynamic var contentLocationMode: LocationMode {
        return .content
    }

    @objc open dynamic var viewMode: ViewMode = .standard {
        didSet {
            if viewMode != oldValue {
                updateMapMode()
                updateTrackingMode()
            }
        }
    }

    @IBInspectable @objc public dynamic var mainMap: Bool = false

    @IBInspectable @objc open dynamic var sizingAction: Int = 0 {
        // 0: Do nothing, 1: Move to annotations, 2: Move to selections
        didSet {
            if sizingAction != oldValue {
                switch sizingAction {
                case 1:
                    viewAnnotations(includesUser: false)

                case 2:
                    viewSelectedObjects()

                default:
                    break
                }
            }
        }
    }

    @IBInspectable @objc open dynamic var selectionAction: Int = 0 {
        // 0: Do nothing, 1: Move to center, 2: Move into view
        didSet {
            if selectionAction != oldValue {
                switch selectionAction {
                case 1:
                    viewSelectedObjects()

                case 2:
                    viewSelectedObjects()

                default:
                    break
                }
            }
        }
    }

    @IBInspectable open var zoomToSingleAnnotation: Bool = false

    @IBInspectable open var zoomPadding: UIEdgeInsets = UIEdgeInsets(top: 66, left: 66, bottom: 66, right: 66) {
        didSet {
            if let _ = (selectionHandler as? PersistSelectionHandler)?.singleSelected {
                viewSelectedObjects()
            }
        }
    }

    @IBInspectable open var zoomSpan: Double = 0.0

    private var zoomDebouncer: Debouncer = Debouncer()

    public var latitudeSpan = 0.01
    public var longitudeSpan = 0.005

    override open var title: String? {
        return "Map"
    }

    override open var icon: UIImage? {
        return UIImage.named("view_map", bundles: Bundle.particles)
    }

    public let defaultZoomLevel: UInt = 10
    @IBInspectable var maxZoomLevel: UInt = 0
    public var debouncer: Debouncer = Debouncer()

    @IBInspectable open var directInteraction: Bool = false
    @IBInspectable open var zoomToSelections: Bool = false

    @objc open dynamic var mapMode: MapMode = .standard {
        didSet {
            (mapView as? MapViewProtocol)?.mapMode = mapMode
            if mapMode != oldValue {
                switch mapMode {
                case .standard:
                    (modeButton as? UIButton)?.setImage(UIImage.named("action_satellite", bundles: Bundle.particles), for: .normal)

                case .satellite:
                    (modeButton as? UIButton)?.setImage(UIImage.named("action_map", bundles: Bundle.particles), for: .normal)

                case .standardFlyover:
                    let image = UIImage.named("action_3d", bundles: Bundle.particles) ?? UIImage.named("action_satellite", bundles: Bundle.particles)
                    (modeButton as? UIButton)?.setImage(image, for: .normal)

                case .satelliteFlyover:
                    let image = UIImage.named("action_3d", bundles: Bundle.particles) ?? UIImage.named("action_map", bundles: Bundle.particles)
                    (modeButton as? UIButton)?.setImage(image, for: .normal)
                }
            }
        }
    }

    @IBOutlet public var mapContainer: UIView? {
        didSet {
            if mapContainer !== oldValue {
                if visible == true {
                    installMapView()
                }
            }
        }
    }

    @IBInspectable public var mapViewXib: String?

    @objc open dynamic var mapView: UIView? {
        didSet {
            if mapView !== oldValue {
                (mapView as? MapViewProtocol)?.mapMode = mapMode

//                refresh()

                if let _ = mapView {
                    add(gesture: UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:))))
                    add(gesture: UIPanGestureRecognizer(target: self, action: #selector(didPan(_:))))
                    add(gesture: UIPinchGestureRecognizer(target: self, action: #selector(didPitch(_:))))
                    add(gesture: UIRotationGestureRecognizer(target: self, action: #selector(didRotate(_:))))

                    locationProvider = LocationProvider.shared
                }
            }
        }
    }

    @IBOutlet public var mapDrawingView: DrawingView? {
        didSet {
            mapDrawingView?.visible = false
            changeObservation(from: oldValue, to: mapDrawingView, keyPath: #keyPath(DrawingView.path)) { [weak self] _, _, _ in
                if let self = self {
                    if self.mapDrawingView?.path == nil {
                        if let points = self.mapDrawingView?.points {
                            self.drawPolygon = self.polygon(points: points)
                        } else {
                            self.drawPolygon = nil
                        }
                    }
                }
            }
        }
    }

    @objc public dynamic var drawPolygon: PolygonObjectProtocol?

    @objc public dynamic var drawing: Bool = false {
        didSet {
            if drawing != oldValue {
                mapDrawingView?.visible = drawing
                if let button = lassoButton as? UIButton {
                    let tintColor = button.tintColor
                    button.tintColor = button.backgroundColor
                    button.backgroundColor = tintColor
                }
            }
        }
    }

    @objc public dynamic var polylineMapView: PolylineMapViewProtocol?
    @objc public dynamic var polygonMapView: PolygonMapViewProtocol?
    @objc public dynamic var circleMapView: CircleMapViewProtocol?

    override open var visible: Bool? {
        didSet {
            if let visible = visible {
                if visible {
                    installMapView()
                } else {
                    uninstallMapView()
                }
            }
        }
    }

    @objc public dynamic var draggingPin: Bool = false
    @objc public dynamic var longPressStart: CLLocation?
    @objc public dynamic var longPressDebouncer: Debouncer = Debouncer()
    @objc public dynamic var longPressLocation: CLLocation?

    @IBOutlet public var locationButton: ButtonProtocol? {
        didSet {
            if locationButton !== oldValue {
                oldValue?.removeTarget()
                locationButton?.addTarget(self, action: #selector(locate(_:)))
            }
        }
    }

    @IBOutlet public var modeButton: ButtonProtocol? {
        didSet {
            if modeButton !== oldValue {
                oldValue?.removeTarget()
                modeButton?.addTarget(self, action: #selector(mode(_:)))
            }
        }
    }

    @IBOutlet public var viewButton: ButtonProtocol? {
        didSet {
            if viewButton !== oldValue {
                oldValue?.removeTarget()
                viewButton?.addTarget(self, action: #selector(view(_:)))
            }
        }
    }

    @IBOutlet public var lassoButton: ButtonProtocol? {
        didSet {
            if lassoButton !== oldValue {
                oldValue?.removeTarget()
                lassoButton?.addTarget(self, action: #selector(draw(_:)))
            }
        }
    }

    @IBOutlet public var noPinsNotice: ViewProtocol? {
        didSet {
            noPinsNotice?.visible = false
            self.updateNoPinsNotice(animated: true)
        }
    }

    open var locationProvider: LocationProviderProtocol? {
        didSet {
            changeObservation(from: oldValue, to: locationProvider, keyPath: #keyPath(LocationProviderProtocol.location)) { [weak self] _, _, _ in
                if let self = self {
                    (self.mapView as? MapViewProtocol)?.showsUserLocation = (self.locationProvider?.location != nil)
                    self.location = self.locationProvider?.location
                }
            }
        }
    }

    open var location: CLLocation? {
        didSet {
            if location != nil, oldValue == nil {
                updateLocation(animated: false)
            }
        }
    }

    @IBAction open func mode(_ sender: Any?) {
        switch mapMode {
        case .standard:
            mapMode = .satellite

        case .satellite:
            mapMode = .standard

        case .standardFlyover:
            mapMode = .satelliteFlyover

        case .satelliteFlyover:
            mapMode = .standardFlyover
        }
    }

    @objc open dynamic var region: Region? {
        didSet {
            if region !== oldValue {
                if mainMap {
                    PlacesService.shared?.area = region?.area
                }
            }
        }
    }

    private var viewDebouncer: Debouncer = Debouncer()

    override open var current: [ModelObjectProtocol]? {
        didSet {
            updateNoPinsNotice(animated: true)
            updateInclusions()
        }
    }

    open var inclusions: [AnnotationProtocol]? {
        didSet {
            updateInclusionsMapArea()
        }
    }

    open var inclusionsMapArea: MapArea? {
        didSet {
            if inclusionsMapArea !== oldValue, inclusionsMapArea != nil {
                updateLocation(animated: true)
            }
        }
    }

    open var polylines: [PolylineProtocol]? {
        if let mapView = mapView as? (UIView & MapViewProtocol) {
            let overlays = mapView.mapOverlays
            let polylines = overlays.compactMap { (overlay) -> MKPolyline? in
                overlay as? MKPolyline
            }
            return polylines.count > 0 ? polylines : nil
        }
        return nil
    }

    open var polygons: [PolygonProtocol]? {
        if let mapView = mapView as? (UIView & MapViewProtocol) {
            let overlays = mapView.mapOverlays
            let polygons = overlays.compactMap { (overlay) -> MKPolygon? in
                overlay as? MKPolygon
            }
            return polygons.count > 0 ? polygons : nil
        }
        return nil
    }

    open var circles: [CircleProtocol]? {
        if let mapView = mapView as? (UIView & MapViewProtocol) {
            let overlays = mapView.mapOverlays
            let circles = overlays.compactMap { (overlay) -> MKCircle? in
                overlay as? MKCircle
            }
            return circles.count > 0 ? circles : nil
        }
        return nil
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        noPinsNotice?.visible = false
        if locationMode == .unknown {
            locationMode = mainMap ? .user : .envelope
        }
    }

    open func changed(new: [ModelObjectProtocol]) -> Bool {
        if new.count == current?.count ?? 0 {
            var changed = false
            for i in 0 ..< new.count {
                if current?[i] !== new[i] {
                    changed = true
                    break
                }
            }
            return changed
        }
        return true
    }

    override open func update() {
        if mapView != nil {
            update(move: false)
        } else {
            current = pending
        }
    }

    override open func updateCompleted(firstContent: Bool) {
        if firstContent {
            updateLocation(animated: true)
        }
    }

    override open func update(diff: Diff, patches: [Patch<ModelObjectProtocol>], current: [ModelObjectProtocol]?) {
        var removing = [MKAnnotation]()
        var adding = [MKAnnotation]()
        for change in patches {
            switch change {
            case let .deletion(index):
                if let annotation = current?[index] as? MKAnnotation {
                    removing.append(annotation)
                }

            case let .insertion(index: _, element: object):
                if let annotation = object as? MKAnnotation, !annotation.coordinate.isEqual(kCLLocationCoordinate2DInvalid) {
                    adding.append(annotation)
                }
            }
        }
        let removingKeys = removing.compactMap { (annotation) -> String? in
            (annotation as? ModelObjectProtocol)?.key ?? nil
        }
        let addingKeys = adding.compactMap { (annotation) -> String? in
            (annotation as? ModelObjectProtocol)?.key ?? nil
        }
        let diff = Set(removingKeys).symmetricDifference(Set(addingKeys))
        let reallyRemove = removing.compactMap { (annotation) -> AnnotationProtocol? in
            if let key = ((annotation as? ModelObjectProtocol)?.key ?? nil) {
                return diff.contains(key) ? (annotation as? AnnotationProtocol) : nil
            }
            return annotation as? AnnotationProtocol
        }
        let reallyAdd = adding.compactMap { (annotation) -> AnnotationProtocol? in
            if let key = ((annotation as? ModelObjectProtocol)?.key ?? nil) {
                return diff.contains(key) ? (annotation as? AnnotationProtocol) : nil
            }
            return annotation as? AnnotationProtocol
        }
        if let mapView = mapView as? MapViewProtocol {
            for annotation in reallyRemove {
                mapView.deselect(annotation: annotation, animated: false)
            }
            mapView.remove(annotations: reallyRemove)
            mapView.add(annotations: reallyAdd)
            view(remove: reallyRemove, add: reallyAdd)
        }
        if let persistedSelection = selectionHandler as? PersistSelectionHandler {
            changed(selected: persistedSelection.selected)
        }
    }

    override open func refresh(animated: Bool, completion: (() -> Void)?) {
        if animated {
            if let handler = viewDebouncer.debounce() {
                handler.run({ [weak self] in
                    if let self = self {
                        self.reallyRefresh()
                        completion?()
                    }
                }, delay: 0.05)
            }
        } else {
            reallyRefresh()
            completion?()
        }
    }

    open func reallyRefresh() {
        if let mapView = self.mapView as? MapViewProtocol {
            mapView.remove(annotations: mapView.mapAnnotations.compactMap({ (annotation) -> AnnotationProtocol? in
                (annotation is ModelObjectProtocol) ? annotation : nil
            }))
            if let current = self.current {
                mapView.add(annotations: current.compactMap({ (model) -> AnnotationProtocol? in
                    model as? AnnotationProtocol
                }))
            }
            if let persistedSelection = selectionHandler as? PersistSelectionHandler {
                changed(selected: persistedSelection.selected)
            }
        }
    }

    @IBAction open func view(_ sender: Any?) {
    }

    @IBAction open func locate(_ sender: Any?) {
        Router.shared?.navigate(to: RoutingRequest(path: "/authorization/location"), animated: true, completion: { [weak self] _, succeeded in
            if succeeded, let self = self {
                (self.mapView as? MapViewProtocol)?.mapShowUserLocation = true
                switch self.locationMode {
                case .unknown:
                    fallthrough
                case .free:
                    fallthrough
                case .follow:
                    if let inclusions = self.inclusions, inclusions.count > 0 {
                        self.locationMode = .content
                    } else {
                        self.locationMode = .user
                    }
                case .content:
                    self.locationMode = .envelope

                case .envelope:
                    self.locationMode = .user

                case .user:
                    self.locationMode = .follow
                }
            }
        })
    }

    @IBAction open func draw(_ sender: Any?) {
        drawing = !drawing
    }

    private var selectionDebouncer: Debouncer = Debouncer()

    override open func changed(selected: [ModelObjectProtocol]?) {
        super.changed(selected: selected)
        locationMode = .unknown
        let handler = selectionDebouncer.debounce()
        handler?.run({ [weak self] in
            if let self = self {
                if let selected = selected?.first {
                    self.move(to: selected as? AnnotationProtocol)
                }
            }
        }, delay: 0.5)
    }

    public var movingDebouncer: Debouncer = Debouncer()

    private var updateNoPinsNoticeDebouncer: Debouncer = Debouncer()

    open func updateNoPinsNotice(animated: Bool) {
        let handler = updateNoPinsNoticeDebouncer.debounce()
        handler?.run({ [weak self] in
            self?.reallyUpdateNoPinsNotice(animated: animated)
        }, delay: shouldShowNoPins() ? 0.04 : 0.01)
    }

    open func reallyUpdateNoPinsNotice(animated: Bool) {
        if let noPinsNotice = self.noPinsNotice as? UIView {
            let shouldShow = shouldShowNoPins()
            if shouldShow != noPinsNotice.visible {
                if animated {
                    if shouldShow != noPinsNotice.visible {
                        UIView.animate(noPinsNotice, type: animated ? .fade : .none, direction: .none, duration: UIView.defaultAnimationDuration, animations: {
                            noPinsNotice.visible = shouldShow
                        }, completion: nil)
                    }
                } else {
                    noPinsNotice.visible = shouldShow
                }
            }
        }
    }

    open func shouldShowNoPins() -> Bool {
        var shouldShow = false
        if let current = current {
            shouldShow = (current.count == 0)
        }
        return shouldShow
    }

    private var zoomToSelectionsDebouncer: Debouncer = Debouncer()

    open func viewSelectedObjects() {
        if zoomToSelections {
            if let handler = zoomToSelectionsDebouncer.debounce() {
                handler.run({ [weak self] in
                    if let self = self {
                        self.view(objects: (self.selectionHandler as? PersistSelectionHandler)?.selected, includesUser: false)
                    }
                }, delay: 0)
            }
        }
    }

    open func view(remove: [AnnotationProtocol], add: [AnnotationProtocol]) {
        DispatchQueue.main.async { [weak self] in
            if let self = self {
                let toAdd = add.compactMap({ (annotation) -> AnnotationProtocol? in
                    (annotation.inclusion != .none) ? annotation : nil
                })
                if toAdd.count > 0 {
                    switch self.locationMode {
                    case .content:
                        self.viewContent(includesUser: false, animated: true)

                    case .envelope:
                        self.viewAnnotations(includesUser: true)

                    default:
                        break
                    }
                }
            }
        }
    }

    open func view(objects: [ModelObjectProtocol]?, includesUser: Bool?) {
        view(annotations: objects?.compactMap({ (object) -> AnnotationProtocol? in
            object as? AnnotationProtocol
        }), includesUser: includesUser)
    }

    open func view(annotations: [AnnotationProtocol]?, includesUser: Bool?, animated: Bool = true) {
        var annotations = annotations ?? [AnnotationProtocol]()
        if let userLocation = userLocation() {
            if includesUser == true {
                annotations.append(userLocation)
            } else if includesUser == nil && annotations.count == 1 {
                annotations.append(userLocation)
            }
        }
        view(annotations: annotations, animated: animated)
    }

    open func view(annotations: [AnnotationProtocol]?, animated: Bool = true) {
        if let annotations = annotations {
            var area = self.area(annotations: annotations)
            if area == nil {
                area = self.area(overlays: circles, annotation: annotations.first)
            }
            if area == nil {
                area = self.area(overlays: polygons, annotation: annotations.first)
            }
            if let area = area {
                if zoomSpan != 0.0 {
                    view(area: area, span: zoomSpan, edgePadding: zoomPadding, animated: animated)
                } else {
                    view(area: area, edgePadding: zoomPadding, animated: animated)
                }
            } else {
                view(annotation: annotations.first, animated: animated)
            }
        }
    }

    func area(annotations: [AnnotationProtocol]?) -> MapArea? {
        if let annotations = annotations, annotations.count > 1 {
            let points = annotations.map { (annotation) -> MapPoint in
                MapPoint(latitude: annotation.annotationCoordinate.latitude, longitude: annotation.annotationCoordinate.longitude)
            }
            return MapArea(points: points)
        }
        return nil
    }

    func area(overlays: [OverlayProtocol]?, annotation: AnnotationProtocol?) -> MapArea? {
        if let overlays = overlays, overlays.count > 0 {
            var points = [MapPoint]()

            if let annotation = annotation {
                points.append(MapPoint(latitude: annotation.annotationCoordinate.latitude, longitude: annotation.annotationCoordinate.longitude))
            }
            for overlay in overlays {
                let rect = overlay.overlayBoundingMapRect
                let ne = rect.northEast.coordinate
                let sw = rect.southWest.coordinate
                points.append(MapPoint(latitude: ne.latitude, longitude: ne.longitude))
                points.append(MapPoint(latitude: sw.latitude, longitude: sw.longitude))
            }
            return MapArea(points: points)
        }
        return nil
    }

    open func view(annotation: AnnotationProtocol?, animated: Bool = true) {
        if zoomToSingleAnnotation {
            zoom(to: annotation, animated: animated)
        } else {
            move(to: annotation, animated: animated)
        }
    }

    open func zoom(to location: CLLocationCoordinate2D, scale: Double? = nil, animated: Bool = true) {
        if let scale = scale {
            (mapView as? MapViewProtocol)?.zoom(to: location, zoomPadding: zoomPadding, scale: scale, animated: animated)
        } else {
            zoom(to: location, zoomLevel: defaultZoomLevel, animated: animated)
        }
    }

    open func zoom(to location: CLLocationCoordinate2D, zoomLevel: UInt, animated: Bool = true) {
        (mapView as? MapViewProtocol)?.zoom(to: location, zoomPadding: zoomPadding, zoomLevel: zoomLevel, animated: animated)
    }

    open func move(to location: CLLocationCoordinate2D, animated: Bool = true) {
        (mapView as? MapViewProtocol)?.move(to: location, zoomPadding: zoomPadding, forced: false, animated: animated)
    }

    open func moveIntoView(coordinate: CLLocationCoordinate2D?, bottom: UIView?, animated: Bool = true) {
        if let coordinate = coordinate, let bottom = bottom {
            (mapView as? MapViewProtocol)?.moveIntoView(coordinate: coordinate, bottom: bottom, animated: animated)
        }
    }

    open func viewAnnotations(includesUser: Bool?, animated: Bool = true) {
        let annotations = (mapView as? MapViewProtocol)?.annotations(includesUser: false)?.compactMap({ (annotation) -> AnnotationProtocol? in
            annotation.inclusion != .none ? annotation : nil
        })
        let narrowed = annotations?.compactMap({ (annotation) -> AnnotationProtocol? in
            annotation.preferedContent ? annotation : nil
        })
        if narrowed?.count ?? 0 > 0 {
            view(annotations: narrowed, includesUser: includesUser, animated: animated)
        } else {
            view(annotations: annotations, includesUser: includesUser, animated: animated)
        }
    }

    open func userLocation() -> AnnotationProtocol? {
        if let userLocation = (mapView as? MapViewProtocol)?.userLocation(), userLocation.annotationCoordinate.latitude != 0.0, userLocation.annotationCoordinate.longitude != 0.0 {
            return userLocation
        }
        return nil
    }

    open func view(area: MapArea, span: Double, edgePadding: UIEdgeInsets, animated: Bool) {
        if let padding = (mapView as? MapViewProtocol)?.padding(for: area, span: span, edgePadding: edgePadding) {
            view(area: area, edgePadding: padding, animated: animated)
        }
    }

    open func view(area: MapArea, edgePadding: UIEdgeInsets, animated: Bool) {
        (mapView as? MapViewProtocol)?.view(area: area, zoomPadding: edgePadding, animated: animated)
    }

    open func zoom(to annotation: AnnotationProtocol?, animated: Bool = true) {
        if let mapView = mapView as? (UIView & MapViewProtocol), let annotation = annotation {
            let bounds = mapView.bounds
            let yPercentage = (zoomPadding.top + (bounds.size.height - zoomPadding.top - zoomPadding.bottom) / 2) / bounds.size.height
            let xPercentage = (zoomPadding.left + (bounds.size.width - zoomPadding.left - zoomPadding.right) / 2) / bounds.size.width
            if CLLocationCoordinate2DIsValid(annotation.annotationCoordinate), annotation.annotationCoordinate.latitude != 0.0 && annotation.annotationCoordinate.longitude != 0.0 {
                //                let region = mapView.region
                //                let span = region.span

                // hard code the span. This seems to be reasonable
                var span = MKCoordinateSpan(latitudeDelta: latitudeSpan, longitudeDelta: longitudeSpan)

                let calculatedCenter = calculate(center: annotation.annotationCoordinate, span: &span, xPercentage: Double(xPercentage), yPercentage: Double(yPercentage))
                mapView.setRegion(MKCoordinateRegion(center: calculatedCenter, span: span), animated: animated)
            }
        }
    }

    open func rect(for overlays: [OverlayProtocol]?, and annotation: AnnotationProtocol?) -> MKCoordinateRegion? {
        if let overlays = overlays {
            var minLatitude: Double?
            var maxLatitude: Double?
            var minLongitude: Double?
            var maxLongitude: Double?

            if let annotation = annotation, CLLocationCoordinate2DIsValid(annotation.annotationCoordinate), annotation.annotationCoordinate.latitude != 0.0, annotation.annotationCoordinate.longitude != 0.0 {
                minLatitude = annotation.annotationCoordinate.latitude
                maxLatitude = minLatitude
                minLongitude = annotation.annotationCoordinate.longitude
                maxLongitude = minLongitude
            }
            for overlay in overlays {
                let rect = overlay.overlayBoundingMapRect
                let ne = rect.northEast.coordinate
                let sw = rect.southWest.coordinate

                if minLatitude == nil {
                    minLatitude = ne.latitude
                    maxLatitude = ne.latitude
                    minLongitude = ne.longitude
                    maxLongitude = ne.longitude
                }
                minLatitude = min_value(ne.latitude, minLatitude)
                minLatitude = min_value(sw.latitude, minLatitude)

                maxLatitude = max_value(ne.latitude, maxLatitude)
                maxLatitude = max_value(sw.latitude, maxLatitude)

                minLongitude = min_value(ne.longitude, minLongitude)
                minLongitude = min_value(sw.longitude, minLongitude)
                maxLongitude = max_value(ne.longitude, maxLongitude)
                maxLongitude = max_value(sw.longitude, maxLongitude)
            }
            if let minLatitude = minLatitude, let minLongitude = minLongitude, let maxLatitude = maxLatitude, let maxLongitude = maxLongitude {
                let lat = (minLatitude + maxLatitude) / 2.0
                let lng = (minLongitude + maxLongitude) / 2.0
                let center = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                let latitudeDelta = maxLatitude - minLatitude
                let longitudeDelta = maxLongitude - minLongitude
                let span = MKCoordinateSpan(latitudeDelta: latitudeDelta * 1.2, longitudeDelta: longitudeDelta * 1.2)
                return MKCoordinateRegion(center: center, span: span)
            }
        }
        return nil
    }

    open func move(to annotation: AnnotationProtocol?, animated: Bool = true) {
        (mapView as? MapViewProtocol)?.move(to: annotation, zoomPadding: zoomPadding, forced: false, animated: animated)
    }

    open func move(to object: ModelObjectProtocol?, animated: Bool = true) {
        move(to: object as? AnnotationProtocol, animated: animated)
    }

    open func zoom(to region: MKCoordinateRegion, animated: Bool = true) {
        (mapView as? MapViewProtocol)?.setRegion(region, animated: true)
    }

    open func installMapView() {
        if let mapContainer = mapContainer, let mapViewXib = mapViewXib, mapView == nil {
            mapView = mapContainer.installView(xib: mapViewXib) as? (UIView & MapViewProtocol)
            polylineMapView = mapView as? PolylineMapViewProtocol
            polygonMapView = mapView as? PolygonMapViewProtocol
            circleMapView = mapView as? CircleMapViewProtocol
            if let mapView = mapView {
                mapContainer.sendSubviewToBack(mapView)
            }
        }
        mapView?.visible = true
    }

    open func uninstallMapView() {
        //        if let _ = mapContainer, let _ = mapViewXib, let mapView = mapView {
        //            mapView.removeFromSuperview()
        //            self.mapView = nil
        //            polylineMapView = nil
        //            polygonMapView = nil
        //        }
        mapView?.visible = false
    }

    open func calculate(center: CLLocationCoordinate2D, span: inout MKCoordinateSpan, xPercentage: Double, yPercentage: Double) -> CLLocationCoordinate2D {
        var yDelta = span.latitudeDelta
        var xDelta = span.longitudeDelta

        if let view = view {
            let ratio = (Double(view.frame.size.height) * yPercentage) / (Double(view.frame.size.width) * xPercentage)
            if yDelta / xDelta > ratio {
                xDelta = yDelta / ratio
            } else {
                yDelta = xDelta * ratio
            }
        }
        span.latitudeDelta = yDelta * (0.5 / yPercentage)
        span.longitudeDelta = xDelta * (0.5 / xPercentage)

        let latitude = center.latitude - span.latitudeDelta * (0.5 - yPercentage)
        let longitude = center.longitude - span.longitudeDelta * (0.5 - xPercentage)
        return CLLocationCoordinate2DMake(latitude, longitude)
    }

    open func polygon(points: [CGPoint]) -> PolygonObjectProtocol? {
        if points.count >= 3 {
            if let mapView = mapView as? (UIView & MapViewProtocol) {
                let coordinates: [CLLocationCoordinate2D] = points.map { (cgPoint) -> CLLocationCoordinate2D in
                    mapView.coordinate(point: cgPoint, from: mapView)
                }
                let polygon = DrawPolygon()
                polygon.polygon = coordinates
                return polygon
            }
        }
        return nil
    }

    public func min_value(_ value1: Double?, _ value2: Double?) -> Double? {
        if let value1 = value1 {
            if let value2 = value2 {
                return min(value1, value2)
            } else {
                return value1
            }
        } else {
            return value2
        }
    }

    public func max_value(_ value1: Double?, _ value2: Double?) -> Double? {
        if let value1 = value1 {
            if let value2 = value2 {
                return max(value1, value2)
            } else {
                return value1
            }
        } else {
            return value2
        }
    }

    open func updateMapMode() {
        switch locationMode {
        case .unknown:
            fallthrough
        case .free:
            fallthrough
        case .content:
            fallthrough
        case .envelope:
            fallthrough
        case .user:
            switch viewMode {
            case .standard:
                mapMode = .standard
            case .satellite:
                mapMode = .satellite
            }

        case .follow:
            switch viewMode {
            case .standard:
                mapMode = .standardFlyover
            case .satellite:
                mapMode = .satelliteFlyover
            }
        }
    }

    open func updateTrackingMode() {
        switch locationMode {
        case .unknown:
            fallthrough
        case .free:
            fallthrough
        case .content:
            fallthrough
        case .envelope:
            (mapView as? MapViewProtocol)?.followingMode = .none

        case .user:
            (mapView as? MapViewProtocol)?.followingMode = .follow

        case .follow:
            (mapView as? MapViewProtocol)?.followingMode = .followWithHeading
        }
    }

    open func updateButtons() {
        switch locationMode {
        case .unknown:
            fallthrough
        case .free:
            (locationButton as? UIButton)?.buttonImage = UIImage.named("action_locate", bundles: Bundle.particles)
            (locationButton as? UIButton)?.tintColor = ColorPalette.shared.color(system: "label")
            break

        case .content:
            (locationButton as? UIButton)?.buttonImage = UIImage.named("action_locate", bundles: Bundle.particles)
            (locationButton as? UIButton)?.tintColor = ColorPalette.shared.color(system: "label")

        case .envelope:
            (locationButton as? UIButton)?.buttonImage = UIImage.named("action_locate", bundles: Bundle.particles)
            (locationButton as? UIButton)?.tintColor = ColorPalette.shared.color(system: "label")

        case .user:
            (locationButton as? UIButton)?.buttonImage = UIImage.named("action_locate", bundles: Bundle.particles)
            if let _ = location {
                (locationButton as? UIButton)?.tintColor = UIColor.blue
            }

        case .follow:
            (locationButton as? UIButton)?.buttonImage = UIImage.named("action_following", bundles: Bundle.particles)
            (locationButton as? UIButton)?.tintColor = UIColor.blue
            break
        }
    }

    open func updateInclusions() {
        inclusions = updateInclusions(items: current)
    }

    public func updateInclusions(items: [ModelObjectProtocol]?) -> [AnnotationProtocol]? {
        return items?.compactMap({ (object) -> AnnotationProtocol? in
            if let annotation = object as? AnnotationProtocol, annotation.inclusion != .none {
                return annotation
            }
            return nil
        })
    }

    public func updateInclusionsMapArea() {
        inclusionsMapArea = updateInclusionsMapArea(annotations: inclusions)
    }

    public func updateInclusionsMapArea(annotations: [AnnotationProtocol]?) -> MapArea? {
        if let points = annotations?.map({ (annotiation) -> MapPoint in
            MapPoint(latitude: annotiation.annotationCoordinate.latitude, longitude: annotiation.annotationCoordinate.longitude)
        }), points.count > 0 {
            return MapArea(points: points)
        } else {
            return nil
        }
    }

    private var locationDebouncer = Debouncer()

    open func updateLocation(animated: Bool) {
        let handler = locationDebouncer.debounce()
        handler?.run({ [weak self] in
            self?.reallyUpdateLocation(animated: animated)
            self?.updateTrackingMode()
        }, delay: 0.1)
    }

    open func reallyUpdateLocation(animated: Bool) {
        switch locationMode {
        case .unknown:
            break

        case .free:
            break

        case .content:
            if let selected = (selectionHandler as? PersistSelectionHandler)?.singleSelected as? AnnotationProtocol {
                let annotations = [selected]
                view(annotations: annotations, includesUser: false, animated: animated)
            } else {
                viewContent(includesUser: false, animated: animated)
            }

        case .envelope:
            if current == nil {
                if let location = location {
                    zoom(to: location.coordinate, zoomLevel: defaultZoomLevel, animated: animated)
                }
            } else {
                if let selected = (selectionHandler as? PersistSelectionHandler)?.singleSelected as? AnnotationProtocol {
                    let annotations = [selected]
                    view(annotations: annotations, includesUser: true, animated: animated)
                } else {
                    viewContent(includesUser: true, animated: animated)
                }
            }

        case .user:
            if let location = location {
                zoom(to: location.coordinate, zoomLevel: defaultZoomLevel, animated: animated)
            }

        case .follow:
            break
        }
    }

    open func viewContent(includesUser: Bool, animated: Bool) {
        viewAnnotations(includesUser: includesUser, animated: animated)
    }
}

extension MapViewListPresenter: UIGestureRecognizerDelegate {
    open func add(gesture: UIGestureRecognizer) {
        if let recognizers = mapView?.gestureRecognizers {
            for recognizer in recognizers {
                if type(of: recognizer) == type(of: gesture) {
                    gesture.require(toFail: recognizer)
                }
            }
        }
        gesture.delegate = self
        mapView?.addGestureRecognizer(gesture)
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UILongPressGestureRecognizer {
            return false
        } else {
            return true
        }
    }

    @objc public func didLongPress(_ sender: UIGestureRecognizer) {
        if mapView === sender.view, let mapView = mapView as? (UIView & MapViewProtocol) {
            switch sender.state {
            case .began:
                if !draggingPin {
                    let point = sender.location(in: mapView)
                    let coordinate = mapView.coordinate(point: point, from: mapView)
                    longPressStart = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    if let handler = longPressDebouncer.debounce() {
                        handler.run({ [weak self] in
                            if let self = self {
                                if self.draggingPin {
                                    self.longPressStart = nil
                                } else {
                                    self.longPressLocation = self.longPressStart
                                }
                            }
                        }, delay: 0.1)
                    }
                }

            case .failed:
                longPressStart = nil
                break
            default:
                break
            }
        }
    }

    @objc public func didPan(_ sender: UIGestureRecognizer) {
        if mapView === sender.view {
            switch sender.state {
            case .ended:
                if (mapView as? MapViewProtocol)?.followingMode != .followWithHeading {
                    locationMode = .unknown
                }

            default:
                break
            }
        }
    }

    @objc public func didPitch(_ sender: UIGestureRecognizer) {
        if mapView === sender.view {
            switch sender.state {
            case .ended:
                if (mapView as? MapViewProtocol)?.followingMode != .followWithHeading {
                    locationMode = .unknown
                }

            default:
                break
            }
        }
    }

    @objc public func didRotate(_ sender: UIGestureRecognizer) {
        if mapView === sender.view {
            switch sender.state {
            case .ended:
                if (mapView as? MapViewProtocol)?.followingMode != .followWithHeading {
                    locationMode = .unknown
                }

            default:
                break
            }
        }
    }
}
