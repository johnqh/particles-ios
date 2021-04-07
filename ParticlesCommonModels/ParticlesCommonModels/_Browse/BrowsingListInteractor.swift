//
//  BrowsingListInteractor.swift
//  InteractorLib
//
//  Created by Qiang Huang on 11/10/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import KVOController
import ParticlesKit
import Utilities

@objc open class BrowsingListInteractor: FilteredListInteractor {
    open var dataCache: DataPoolInteractor? {
        didSet {
            changeObservation(from: oldValue, to: dataCache, keyPath: #keyPath(DataPoolInteractor.data)) { [weak self] _, _, _ in
                self?.filter()
            }
        }
    }

    open override var data: [ModelObjectProtocol]? {
        if let values = dataCache?.data?.values {
            return Array(values)
        } else {
            return nil
        }
    }

    open override func filter(data: ModelObjectProtocol, key: String, value: Any) -> Bool {
        switch key {
        default:
            return true
        }
    }
}
