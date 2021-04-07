//
//  LoaderProtocol.swift
//  LoaderLib
//
//  Created by Qiang Huang on 10/11/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import Foundation

// loadingTime is used for differentiated loading
// if error is not nil, something happened
public typealias LoaderCompletionHandler = (_ loadedObject: Any?, _ loadTime: Date?, _ error: Error?) -> Void

public protocol LoaderProtocol {
    func load(params: [String: Any]?, completion: LoaderCompletionHandler?)
    func parse(data: Any?, error: Error?, completion: LoaderCompletionHandler?)
    func save(object: Any?)
    func createEntity() -> ModelObjectProtocol
}
