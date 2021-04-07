//
//  PagedWebApi.swift
//  WebApiLib
//
//  Created by Qiang Huang on 11/2/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import Utilities

open class PagedWebApi<WebApiClass>: NSObject, IOProtocol where WebApiClass: WebApi {
    public var priority: Int = 10
    public var page: Int
    public var limit: Int
    public var api: WebApiClass?

    public required init(page: Int, limit: Int) {
        self.page = page
        self.limit = limit
        super.init()
    }

    public func load(path: String, params: [String: Any]?, completion: @escaping IOReadCompletionHandler) {
        load(path: path, page: page, params: params, completion: completion)
    }

    public func load(path: String, page: Int, params: [String: Any]?, completion: @escaping IOReadCompletionHandler) {
        api = WebApiClass(priority: priority)
        let merged = DictionaryUtils.merge(params, with: param(page: page))
        api?.load(path: path, params: merged, completion: completion)
    }

    public func save(path: String, params: [String: Any]?, data: Any?, completion: IOWriteCompletionHandler?) {
    }

    public func modify(path: String, params: [String: Any]?, data: Any?, completion: IOWriteCompletionHandler?) {
    }

    public func delete(path: String, params: [String: Any]?, completion: IODeleteCompletionHandler?) {
    }

    open func param(page: Int) -> [String: Any]? {
        return nil
    }
}
