//
//  FieldsViewController.swift
//  FieldPresenterLib
//
//  Created by John Huang on 10/15/18.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import JedioKit
import KVOController
import ParticlesKit
import PlatformParticles
import UIToolkits
import Utilities

open class FieldsViewController: DataPresenterViewController {
    open var fieldsEntity: FieldsEntityInteractor = FieldsEntityInteractor()

    open var entityFields: ListInteractor? {
        didSet {
            if entityFields !== oldValue {
                fieldsEntity.list = entityFields
            }
            changeObservation(from: oldValue, to: entityFields, keyPath: #keyPath(ListInteractor.list)) { [weak self] _, _, _ in
                self?.sync()
            }
        }
    }

    @IBOutlet open var fieldLoader: FieldLoader? {
        didSet {
            fieldsEntity.fieldLoader = fieldLoader
        }
    }

    open var dataCache: LocalEntityCacheInteractor? {
        didSet {
            changeObservation(from: oldValue, to: dataCache, keyPath: #keyPath(LocalEntityCacheInteractor.entity)) { [weak self] _, _, _ in
                if let self = self {
                    self.entity = self.dataCache?.entity
                }
            }
        }
    }

    override open var entity: ModelObjectProtocol? {
        didSet {
            if entity !== oldValue {
                fieldsEntity.entity = editingObject
            }
        }
    }

    open var editingObject: ModelObjectProtocol? {
        return entity
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        entityFields = ListInteractor()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardObserver()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        keyboardObserver = nil
    }

    open func sync() {
        presenterManager?.listInteractor?.sync(entityFields?.list)
    }
}
