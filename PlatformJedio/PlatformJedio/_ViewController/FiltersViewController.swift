//
//  FiltersViewController.swift
//  FieldPresenterLib
//
//  Created by Qiang Huang on 11/2/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import ParticlesKit
import RoutingKit
import UIToolkits
import Utilities

open class FiltersViewController<FilterEntityClass>: FieldsViewController where FilterEntityClass: FilterEntity & SingletonProtocol {
    @IBOutlet var doneButton: ButtonProtocol?

    public var persisted: FilterEntity? {
        return FilterEntityClass.shared
    }

    public var filters: FilterEntity? {
        return entity as? FilterEntity
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        if let persisted = persisted {
            entity = FilterEntity(copy: persisted)
        }
    }

    @IBAction func apply(_ sender: Any?) {
        if let persisted = persisted {
            filters?.apply(to: persisted)
        }
        dismiss(sender)
    }
}
