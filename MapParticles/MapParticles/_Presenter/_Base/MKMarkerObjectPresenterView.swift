//
//  MKMarkerAnnotationView+ObjectPresenter.swift
//  PresenterLib
//
//  Created by Qiang Huang on 11/28/18.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import MapKit
import ParticlesKit

open class MKMarkerObjectPresenterView: MKMarkerAnnotationView, ObjectPresenterProtocol {
    public var selectable: Bool = false
    public var model: ModelObjectProtocol? {
        get { return annotation as? ModelObjectProtocol }
        set { annotation = newValue as? MKAnnotation }
    }

    open override var annotation: MKAnnotation? {
        didSet {
            updateMarker(object: model)
        }
    }

    open func updateMarker(object: ModelObjectProtocol?) {
    }
}
