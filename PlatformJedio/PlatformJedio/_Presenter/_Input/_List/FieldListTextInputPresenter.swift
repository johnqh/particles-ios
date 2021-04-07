//
//  FieldListTextInputPresenter.swift
//  PlatformJedio
//
//  Created by Qiang Huang on 11/28/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import ParticlesKit

@objc open class FieldListTextInputPresenter: FieldListInputPresenter {
    private var string: String? {
        get { return field?.string }
        set { field?.string = newValue }
    }

    override var tableView: UITableView? {
        didSet {
            tableView?.allowsMultipleSelection = false
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
