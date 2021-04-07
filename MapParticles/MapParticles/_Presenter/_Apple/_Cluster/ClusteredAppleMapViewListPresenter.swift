//
//  ClusteredAppleMapViewListPresenter.swift
//  MapParticles
//
//  Created by Qiang Huang on 10/21/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import MapKit
import OCMapView
import ParticlesKit

open class ClusteredAppleMapViewListPresenter: AppleMapViewListPresenter {
    public var clusteredMapView: ClusteredMapView? {
        return mapView as? ClusteredMapView
    }

    @objc open dynamic override var mapView: UIView? {
        didSet {
            if mapView !== oldValue {
                if let clusteredMapView = clusteredMapView {
                    clusteredMapView.clusterSize = 0.15
                    clusteredMapView.clusteringMethod = OCClusteringMethodGrid
                }
            }
        }
    }

    open override func update() {
        updateClustering(for: pending)
        super.update()
    }

    open func updateClustering(for model: [ModelObjectProtocol]?) {
        if let clusteredMapView = clusteredMapView {
            let mapViewPixels = clusteredMapView.frame.size.width * clusteredMapView.frame.size.height
            clusteredMapView.clusteringEnabled = (model?.count ?? 0) > Int(mapViewPixels / (44.0 * 44.0)) / 2
        }
    }
}
