//
//  JsonDocumentFileCaching.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 12/26/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import Utilities

open class JsonDocumentFileCaching: NSObject, JsonCachingProtocol {
    public var priority: Int = 0

    public var debouncer: Debouncer = Debouncer()
    public var folder: String?
    public func file(path: String) -> String? {
        if folder == nil {
            folder = FolderService.shared?.documents()
        }
        return folder?.stringByAppendingPathComponent(path: path).stringByAppendingPathComponent(path: "data.json")
    }

    public init(priority: Int = 0) {
        super.init()
        self.priority = priority
    }

    open func read(path: String, completion: @escaping JsonReadCompletionHandler) {
        if let file = file(path: path) {
//            DispatchQueue.global().async {
            let object = JsonLoader.load(file: file)
//                DispatchQueue.main.async {
            completion(object, nil)
//                }
//            }
        } else {
            completion(nil, nil)
        }
    }

    open func write(path: String, data: Any?, completion: JsonWriteCompletionHandler?) {
        if let file = file(path: path) {
            if let handler = debouncer.debounce() {
                handler.run(background: {
                    JsonWriter.write(data, to: file)
                }, final: {
                    completion?(nil)
                }, delay: 0.5)
            }
        } else {
            completion?(NSError(domain: "file", code: 0, userInfo: ["message": "document folder error"]))
        }
    }
}
