//
//  Loader.swift
//  ParticlesKit
//
//  Created by John Huang on 12/29/18.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import Utilities

open class Loader<EntityClass>: NSObject, LoaderProtocol where EntityClass: NSObject & ModelObjectProtocol & ParsingProtocol {
    internal var path: String
    internal var io: [IOProtocol]
    internal var fields: [String]?
    internal var loadTime: Date?
    internal var lastPriority: Int?
    internal var readerDebounce: Debouncer = Debouncer()
    internal var writerDebounce: Debouncer = Debouncer()
    public weak var cache: LocalCacheProtocol?

    public init(path: String, io: [IOProtocol], fields: [String]? = nil, cache: LocalCacheProtocol? = nil) {
        self.path = path
        self.io = io
        self.fields = fields
        self.cache = cache
        super.init()
    }

    open func load(params: [String: Any]?, completion: LoaderCompletionHandler?) {
        if let handler = readerDebounce.debounce() {
            handler.run({ [weak self] in
                if let self = self {
                    self.lastPriority = nil
                    for i in 0 ..< self.io.count {
                        let ioLoader = self.io[i]
                        ioLoader.priority = i
                        ioLoader.load(path: self.path, params: params) { [weak self] (data: Any?, _: Any?, priority: Int, error: Error?) in
                            handler.run({ [weak self] in
                                if let self = self {
                                    let lastPriority = self.lastPriority ?? -1
                                    if priority > lastPriority {
                                        self.lastPriority = priority
                                        if let data = data {
                                            self.parse(data: data, error: error, completion: completion)
                                        } else {
                                            completion?(data, nil, error)
                                        }
                                    }
                                }
                            }, delay: nil)
                        }
                    }
                }
            }, delay: nil)
        }
    }

    open func parse(data: Any?, error: Error?, completion: LoaderCompletionHandler?) {
        if let entities = parseEntities(data: data) {
            completion?(entities, loadTime, error)
        } else if let entity = parseEntity(data: data) {
            completion?(entity, loadTime, error)
        } else {
            completion?(nil, loadTime, error)
        }
    }

    private func parseEntities(data: Any?) -> [ModelObjectProtocol]? {
        if let result = result(data: data) {
            if let array = result as? [Any] {
                var entities = [ModelObjectProtocol]()
                for entityData in array {
                    if let entity = entity(data: entityData) {
                        entities.append(entity)
                    }
                }
                return entities
            } else if let dictionary = result as? [String: Any], let trunk = dictionary.values.first as? [String: [String: Any]] {
                var entities = [ModelObjectProtocol]()
                for (_, entityData) in trunk {
                    if let entity = entity(data: entityData) {
                        entities.append(entity)
                    }
                }
                return entities
            }
        }
        return nil
    }

    open func result(data: Any?) -> Any? {
        return data
    }

    private func parseEntity(data: Any?) -> ModelObjectProtocol? {
        if let result = result(data: data) {
            return entity(data: result)
        }
        return nil
    }

    open func entity(data: Any?) -> ModelObjectProtocol? {
        if let entityData = data as? [String: Any] {
            let obj = entity(from: entityData)
            (obj as? ParsingProtocol)?.parse?(dictionary: entityData)
            return obj
        }
        return nil
    }

    open func entity(from data: [String: Any]?) -> ModelObjectProtocol {
        if let entity = cache?.entity(from: data) {
            return entity
        }
        return createEntity()
    }

    open func createEntity() -> ModelObjectProtocol {
        return EntityClass()
    }

    open func save(object: Any?) {
        if lastPriority == io.count - 1 {
            if let entity = object as? JsonPersistable, let data = entity.json {
                save(data: data)
            } else if let entities = object as? [JsonPersistable] {
                var data = [[String: Any]]()
                for entity in entities {
                    if let entityData = entity.json {
                        data.append(entityData)
                    }
                }
                save(data: data)
            } else if let entities = object as? [String: JsonPersistable] {
                var data = [[String: Any]]()
                for (_, entity) in entities {
                    if let entityData = entity.json {
                        data.append(entityData)
                    }
                }
                save(data: data)
            }
        }
    }

    open func save(data: Any?) {
        if let handler = writerDebounce.debounce() {
            handler.run({ [weak self] in
                if let self = self {
                    for i in 0 ..< self.io.count {
                        let ioLoader = self.io[i]
                        if !(ioLoader is ApiProtocol) {
                            ioLoader.save(path: self.path, params: nil, data: data, completion: nil)
                        }
                    }
                }
            }, delay: nil)
        }
    }
}
