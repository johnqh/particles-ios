//
//  MapViewCircleListPresenter.swift
//  MapParticles
//
//  Created by Qiang Huang on 2/2/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import MapKit
import ParticlesKit
import PlatformParticles
import UIToolkits
import Utilities

open class MapViewCircleListPresenter: NativeListPresenter {
    public var debouncer: Debouncer = Debouncer()

    @IBOutlet public var mapView: CircleMapViewProtocol? {
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
                var circles: [CircleObjectProtocol]?
                handler.run(background: {
                    circles = list.compactMap { (item) -> CircleObjectProtocol? in
                        if let circle = item as? CircleObjectProtocol {
                            if circle.valid {
                                return circle
                            }
                        }
                        return nil
                    }
                }, final: { [weak self] in
                    if let self = self {
                        self.mapView?.removeCircles()
                        if let circles = circles {
                            self.mapView?.add(circles: circles)
                        }
                        completion?()
                    }
                }, delay: 0)
            }
        } else {
            mapView?.removeCircles()
            completion?()
        }
    }
}
