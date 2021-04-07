//
//  FieldGridStringsInputPresenter.swift
//  FieldPresenterLib
//
//  Created by Qiang Huang on 10/24/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import Utilities

@objc open class FieldGridStringsInputPresenter: FieldGridInputPresenter {
    override var collectionView: UICollectionView? {
        didSet {
            collectionView?.allowsSelection = true
            collectionView?.allowsMultipleSelection = true
        }
    }

    override open func isSelected(value: Any?) -> Bool {
        if let string = parser.asString(value) {
            return field?.strings?.contains(string) ?? false
        }
        return false
    }

    override open func select(value: Any?) {
        if let string = parser.asString(value) {
            var strings = field?.strings ?? [String]()
            if !strings.contains(string) {
                strings.append(string)
                field?.strings = strings
            }
        }
    }

    override open func deselect(value: Any?) {
        if let string = parser.asString(value) {
            var strings = field?.strings ?? [String]()
            if let index = strings.firstIndex(of: string) {
                strings.remove(at: index)
                field?.strings = strings
            }
        }
    }
}
