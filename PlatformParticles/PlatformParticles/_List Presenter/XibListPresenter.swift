//
//  XibListPresenter.swift
//  PresenterLib
//
//  Created by Qiang Huang on 10/9/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import ParticlesKit
import UIToolkits
import Utilities

open class XibListPresenter: NativeListPresenter, XibPresenterProtocol {
    public var xibCache: XibPresenterCache = XibPresenterCache()

    @IBInspectable public var xibMap: String? {
        didSet {
            xibCache.xibMap = xibMap
        }
    }

    public var xibRegister: XibRegisterProtocol?

    public func xib(object: ModelObjectProtocol?) -> String? {
        if let xibFile = xibCache.xib(object: object) {
            xibRegister?.registerXibIfNeeded(xibFile)
            return xibFile
        }
        return nil
    }

    public func defaultSize(at index: Int) -> CGSize? {
        if let object = self.object(at: index), let xib = self.xib(object: object) {
            return defaultSize(xib: xib)
        }
        return nil
    }
}
