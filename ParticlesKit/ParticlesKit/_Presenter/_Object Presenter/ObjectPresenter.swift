//
//  ObjectPresenter.swift
//  PresenterLib
//
//  Created by Qiang Huang on 10/10/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import Utilities

@objc public protocol ObjectPresenterProtocol {
    @objc var model: ModelObjectProtocol? { get set }
    @objc optional var selectable: Bool { get }
}

@objc public protocol SelectableProtocol {
    @objc var isSelected: Bool { get set }
}

@objc open class ObjectPresenter: NSObject, ObjectPresenterProtocol {
    @IBOutlet @objc open dynamic var model: ModelObjectProtocol?
//    public var debouncer: Debouncer = Debouncer()

    @objc open dynamic var isFirst: Bool = false
    @objc open dynamic var isLast: Bool = false

    @objc open dynamic var selectable: Bool {
        return true
    }
}

@objc public protocol ObjectTableCellPresenterProtocol {
    var showDisclosure: Bool { get }
}
