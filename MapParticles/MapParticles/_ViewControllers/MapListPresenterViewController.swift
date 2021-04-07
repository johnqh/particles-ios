//
//  MapListPresenterViewController.swift
//  MapParticles
//
//  Created by Qiang Huang on 8/29/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import FloatingPanel
import PlatformParticles
import UIToolkits

open class MapListPresenterViewController: ListPresenterViewController {
    open var mapPresenter: MapViewListPresenter? {
        didSet {
            changeObservation(from: oldValue, to: mapPresenter, keyPath: #keyPath(MapViewListPresenter.locationMode)) { [weak self] _, object, _ in
                if let self = self, !(object is NSNull) {
                    if let embedding: UIViewControllerEmbeddingProtocol = self.parentViewControllerConforming(protocol: UIViewControllerEmbeddingProtocol.self) as? UIViewControllerEmbeddingProtocol, let floated = embedding.floated as? FloatingPanelLayout {
                        if floated.supportedPositions.contains(.tip) {
                            embedding.floated?.move(to: .tip)
                        }
                    }
                }
            }
            changeObservation(from: oldValue, to: mapPresenter, keyPath: #keyPath(MapViewListPresenter.polylineMapView)) { [weak self] _, _, _ in
                if let self = self {
                    self.updatePolylines()
                }
            }
            changeObservation(from: oldValue, to: mapPresenter, keyPath: #keyPath(MapViewListPresenter.polygonMapView)) { [weak self] _, _, _ in
                if let self = self {
                    self.updatePolygons()
                }
            }
            changeObservation(from: oldValue, to: mapPresenter, keyPath: #keyPath(MapViewListPresenter.circleMapView)) { [weak self] _, _, _ in
                if let self = self {
                    self.updateCircles()
                }
            }
        }
    }

    @IBOutlet open var polylinePresenter: MapViewPolylineListPresenter? {
        didSet {
            if polylinePresenter !== oldValue {
                updatePolylines()
            }
        }
    }

    @IBOutlet open var polygonPresenter: MapViewPolygonListPresenter? {
        didSet {
            if polygonPresenter !== oldValue {
                updatePolygons()
            }
        }
    }

    @IBOutlet open var circlePresenter: MapViewCircleListPresenter? {
        didSet {
            if circlePresenter !== oldValue {
                updateCircles()
            }
        }
    }

    override open func awakeFromNib() {
        super.awakeFromNib()

        mapPresenter = presenterManager?.presenters?.first(where: { (presenter) -> Bool in
            (presenter as? MapViewListPresenter) != nil
        }) as? MapViewListPresenter
    }

    open func updatePolylines() {
        if let mapPresenter = mapPresenter {
            polylinePresenter?.mapView = mapPresenter.polylineMapView
        }
    }

    open func updatePolygons() {
        if let mapPresenter = mapPresenter {
            polygonPresenter?.mapView = mapPresenter.polygonMapView
        }
    }

    open func updateCircles() {
        if let mapPresenter = mapPresenter {
            circlePresenter?.mapView = mapPresenter.circleMapView
        }
    }
}
