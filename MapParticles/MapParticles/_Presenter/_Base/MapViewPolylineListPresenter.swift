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

open class MapViewPolylineListPresenter: NativeListPresenter {
    public var debouncer: Debouncer = Debouncer()

    @IBOutlet public var mapView: PolylineMapViewProtocol? {
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
                var polylines: [PolylineObjectProtocol]?
                handler.run(background: {
                    polylines = list.compactMap { (item) -> PolylineObjectProtocol? in
                        if let polyline = item as? PolylineObjectProtocol {
                            if polyline.valid {
                                return polyline
                            }
                        }
                        return nil
                    }
                }, final: { [weak self] in
                    if let self = self {
                        self.mapView?.removePolylines()
                        if let polylines = polylines {
                            self.mapView?.add(polylines: polylines)
                        }
                        completion?()
                    }
                }, delay: 0)
            }
        } else {
            mapView?.removePolylines()
            completion?()
        }
    }
}
