//
//  ModelProtocol.swift
//  EntityLib
//
//  Created by John Huang on 11/19/18.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import CoreLocation
import Utilities

@objc public protocol ModelObjectProtocol: NSObjectProtocol {
    @objc optional weak var parent: ModelObjectProtocol? { get set }
    @objc optional var index: Int { get set }
    @objc optional var key: String? { get }
    @objc optional var displayTitle: String? { get }
    @objc optional var displaySubtitle: String? { get }
    @objc optional var displayImageUrl: String? { get }
    @objc optional var isSelected: Bool { get set }

    @objc optional func children(tag: String?) -> [ModelObjectProtocol]?
    @objc optional func order(ascending another: ModelObjectProtocol?) -> Bool
}

public protocol GraphingObjectProtocol: ModelObjectProtocol {
    var x: Float? { get }
    var y: Float? { get }
}

@objc public protocol FilterableProtocol: NSObjectProtocol {
    @objc func filter(lowercased: String?) -> Bool
}

@objc public protocol ClusteredModelObjectProtocol: ModelObjectProtocol {
    @objc var cluster: [ModelObjectProtocol]? { get }
}

@objc public protocol DirtyProtocol: NSObjectProtocol {
    @objc var dirty_time: Date? { get set }
    @objc var dirty: Bool { get set }
}

@objc public protocol ModelListProtocol: ModelObjectProtocol {
    var list: [ModelObjectProtocol]? { get set }
}

@objc public protocol ModelGridProtocol: ModelObjectProtocol {
    var grid: [[ModelObjectProtocol]]? { get set }
    var width: Int { get }
    var height: Int { get }
}

public protocol DateModelObjectProtocol: ModelObjectProtocol {
    var date: Date? { get }
}

public protocol JsonPersistable {
    var json: [String: Any]? { get set }
    var thinned: [String: Any]? { get }
}

public protocol LocalCacheProtocol: NSObjectProtocol {
    func entity(from data: [String: Any]?) -> ModelObjectProtocol?
}

@objc public enum AnnotationInclusion: Int {
    case none // do not zoom to annotation
    case ifNone // only zoom to annotation if there are no annotation previously
    case always // always zoom to annotation
}

public protocol AnnotationProtocol: NSObjectProtocol {
    var annotationCoordinate: CLLocationCoordinate2D { get }
    var annotationTitle: String? { get }
    var annotationSubtitle: String? { get }
    var inclusion: AnnotationInclusion { get }
    var preferedContent: Bool { get }
}
