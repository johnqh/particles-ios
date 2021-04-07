//
//  FieldListIntInputPresenter.swift
//  PlatformJedio
//
//  Created by Qiang Huang on 11/28/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import ParticlesKit

@objc open class FieldListIntInputPresenter: FieldListInputPresenter {
    private var int: Int? {
        get { return field?.int }
        set { field?.int = newValue }
    }

    override var tableView: UITableView? {
        didSet {
            tableView?.allowsMultipleSelection = false
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
