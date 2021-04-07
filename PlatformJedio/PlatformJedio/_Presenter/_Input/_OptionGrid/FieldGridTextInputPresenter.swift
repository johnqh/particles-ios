//
//  FieldGridTextInputPresenter.swift
//  FieldPresenterLib
//
//  Created by Qiang Huang on 10/24/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import ParticlesKit

@objc open class FieldGridTextInputPresenter: FieldGridInputPresenter {
    private var string: String? {
        get { return field?.string }
        set { field?.string = newValue }
    }

    override var collectionView: UICollectionView? {
        didSet {
            collectionView?.allowsMultipleSelection = false
        }
    }

    override open func isSelected(value: Any?) -> Bool {
        return string == parser.asString(value)
    }

    override open func select(value: Any?) {
        string = parser.asString(value)
    }

    override open func deselect(value: Any?) {
        if isSelected(value: value) {
            string = nil
        }
    }
}
