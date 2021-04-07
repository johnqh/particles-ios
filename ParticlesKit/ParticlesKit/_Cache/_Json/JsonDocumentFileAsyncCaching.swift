//
//  JsonDocumentFileAsyncCaching.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 12/29/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import Utilities

open class JsonDocumentFileAsyncCaching: JsonDocumentFileCaching {
    open override func read(path: String, completion: @escaping JsonReadCompletionHandler) {
        if let file = file(path: path) {
            DispatchQueue.global().async {
                let object = JsonLoader.load(file: file)
                DispatchQueue.main.async {
                    completion(object, nil)
                }
            }
        } else {
            completion(nil, nil)
        }
    }
}
