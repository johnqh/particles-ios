//
//  PlacemarkProtocols.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 8/29/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import MapKit

public protocol PlacemarkProtocol: AnnotationProtocol {
    var color: String? { get }
    var imageUrl: String? { get }
    var placemarkName: String? { get }
}
