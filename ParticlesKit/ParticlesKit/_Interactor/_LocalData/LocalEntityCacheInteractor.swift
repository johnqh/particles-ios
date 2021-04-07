//
//  LocalEntityCacheInteractor.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 12/25/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import KVOController
import Utilities

@objc open class LocalEntityCacheInteractor: LocalJsonCacheInteractor, InteractorProtocol {
    @objc open dynamic var entity: ModelObjectProtocol? {
        didSet {
            changeObservation(from: oldValue, to: entity, keyPath: #keyPath(DictionaryEntity.data)) { [weak self] _, _, _ in
                self?.save()
            }
        }
    }

    public var dictionaryEntity: DictionaryEntity? {
        return entity as? DictionaryEntity
    }

    public override init() {
        super.init()
    }

    public override init(key: String? = nil, default defaultJson: String? = nil) {
        super.init(key: key, default: defaultJson)
    }

    open override func createLoader() -> LoaderProtocol? {
        if let path = path {
            return Loader<DictionaryEntity>(path: path, io: [JsonDocumentFileCaching()], cache: self)
        }
        return nil
    }

    open override func entity(from data: [String: Any]?) -> ModelObjectProtocol? {
        return entity ?? entityObject()
    }

    open func entityObject() -> ModelObjectProtocol {
        return DictionaryEntity()
    }

    open override func receive(object: Any?, loadTime: Date?, error: Error?) {
        if error == nil {
            process(object: object as? (ModelObjectProtocol))
        }
    }

    open func process(object: ModelObjectProtocol?) {
        if let object = object {
            entity = object
        } else {
            entity = entityObject()
        }
    }

    open override func save() {
        loader?.save(object: entity)
    }
}
