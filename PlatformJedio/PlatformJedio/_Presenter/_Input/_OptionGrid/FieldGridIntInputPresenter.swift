//
//  FieldGridTextInputPresenter.swift
//  FieldPresenterLib
//
//  Created by Qiang Huang on 10/24/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import ParticlesKit

@objc open class FieldGridIntInputPresenter: FieldGridInputPresenter {
    private var int: Int? {
        get { return field?.int }
        set { field?.int = newValue }
    }

    override var collectionView: UICollectionView? {
        didSet {
            collectionView?.allowsMultipleSelection = false
        }
    }

    override open func isSelected(value: Any?) -> Bool {
        return int == parser.asNumber(value)?.intValue
    }

    override open func select(value: Any?) {
        int = parser.asNumber(value)?.intValue
    }

    override open func deselect(value: Any?) {
        if isSelected(value: value) {
            int = nil
        }
    }
}
