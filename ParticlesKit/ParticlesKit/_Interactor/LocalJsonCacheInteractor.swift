//
//  LocalJsonCacheInteractor.swift
//  InteractorLib
//
//  Created by Qiang Huang on 11/10/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import Utilities

@objc open class LocalJsonCacheInteractor: NSObject, LocalCacheProtocol {
    @objc open var key: String?
    open var defaultJson: String?
    private var _loader: LoaderProtocol?
    public var loader: LoaderProtocol? {
        if _loader == nil {
            _loader = createLoader()
        }
        return _loader
    }

    public var path: String? {
        if let key = key {
            return "\(String(describing: type(of: self))).persist.\(key)"
        }
        return nil
    }

    open var loadingParams: [String: Any]? {
        return nil
    }

    public override init() {
        super.init()
    }

    public init(key: String? = nil, default defaultJson: String? = nil) {
        super.init()
        self.key = key
        self.defaultJson = defaultJson
        load()
    }

    open func createLoader() -> LoaderProtocol? {
        return nil
    }

    open func load() {
        loader?.load(params: loadingParams, completion: { [weak self] (object: Any?, loadTime: Date?, error: Error?) in
            self?.receive(object: object, loadTime: loadTime, error: error)
        })
    }

    open func entity(from data: [String: Any]?) -> ModelObjectProtocol? {
        return nil
    }

    open func receive(object: Any?, loadTime: Date?, error: Error?) {
    }

    open func save() {
    }
}
