//
//  MapViewPolylineListPresenter.swift
//  MapParticles
//
//  Created by Qiang Huang on 10/25/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import MapKit
import ParticlesKit
import PlatformParticles
import UIToolkits
import Utilities

open class MapViewPolygonListPresenter: NativeListPresenter {
    public var debouncer: Debouncer = Debouncer()

    @IBOutlet public var mapView: PolygonMapViewProtocol? {
        didSet {
            if mapView !== oldValue {
                refresh(animated: false) { [weak self] in
                    self?.updateCompleted(firstContent: true)
                }
            }
        }
    }

    override open func update() {
        let firstContent = (current == nil)
        current = pending
        refresh(animated: true) { [weak self] in
            self?.updateCompleted(firstContent: firstContent)
        }
    }

    override open func refresh(animated: Bool, completion: (() -> Void)?) {
        if let list = interactor?.list {
            if let handler = debouncer.debounce() {
                var polygons: [PolygonObjectProtocol]?
                handler.run(background: {
                    polygons = list.compactMap { (item) -> PolygonObjectProtocol? in
                        if let polygon = item as? PolygonObjectProtocol {
                            if polygon.valid {
                                return polygon
                            }
                        }
                        return nil
                    }
                }, final: { [weak self] in
                    if let self = self {
                        self.mapView?.removePolygons()
                        if let polygons = polygons {
                            self.mapView?.add(polygons: polygons)
                        }
                        completion?()
                    }
                }, delay: 0)
            }
        } else {
            mapView?.removePolygons()
            completion?()
        }
    }
}
