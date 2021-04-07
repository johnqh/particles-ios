//
//  DataListInteractor.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 12/27/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import Foundation

@objc open class DataListInteractor: LocalJsonCacheInteractor {
    @objc open dynamic var data: [ModelObjectProtocol]?

    open override func receive(object: Any?, loadTime: Date?, error: Error?) {
        if error == nil {
            data = object as? [ModelObjectProtocol]
        }
    }
}
