//
//  ObjectInteractor.swift
//  InteractorLib
//
//  Created by Qiang Huang on 11/23/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import Utilities

@objc open class LoadingObjectInteractor: NSObject, LoadingInteractorProtocol {
    open var listManager: DataPoolInteractor?
    open var loader: LoaderProtocol?

    open var objectKey: String? {
        didSet {
            if objectKey != oldValue {
                loadEntity()
            }
        }
    }

    open var loadingParams: [String: Any]? {
        return nil
    }

    @objc open dynamic var entity: ModelObjectProtocol?

    open func loadEntity() {
        if let objectKey = objectKey {
            entity = listManager?.data?[objectKey]
        } else {
            entity = nil
        }

        if let loadingParams = loadingParams, let objectKey = objectKey {
            loader?.load(params: loadingParams, completion: { [weak self] (entity: Any?, _: Date?, _: Error?) in
                if self?.objectKey == objectKey {
                    self?.entity = entity as? (ModelObjectProtocol)
                }
            })
        }
    }
}
