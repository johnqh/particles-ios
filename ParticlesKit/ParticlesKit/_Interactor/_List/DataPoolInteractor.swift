//
//  DataPoolInteractor.swift
//  InteractorLib
//
//  Created by John Huang on 11/10/18.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import Utilities

@objc open class DataPoolInteractor: LocalJsonCacheInteractor {
    @objc open dynamic var data: [String: ModelObjectProtocol]?

    private var saveDebouncer: Debouncer = Debouncer()

    override open func receive(object: Any?, loadTime: Date?, error: Error?) {
        if let error = error {
            if (error as NSError).code == 403 || (error as NSError).code == 204 {
                data = nil
            } else {
                let temp = data
                data = temp
            }
        } else {
            if let entities = object as? [ModelObjectProtocol] {
                var parsed = [String: ModelObjectProtocol]()
                for entity in entities {
                    if let key = entity.key {
                        if let key = key {
                            parsed[key] = entity
                        }
                    }
                }
                data = parsed
                save()
            } else {
                data = [:]
            }
        }
    }

    override open func save() {
        if let handler = saveDebouncer.debounce() {
            handler.run({ [weak self] in
                self?.loader?.save(object: self?.data)
            }, delay: 1)
        }
    }
}
