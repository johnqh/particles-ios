//
//  UIView+Xib.swift
//  PresenterLib
//
//  Created by Qiang Huang on 10/10/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import Masonry
import ParticlesKit
import UIKit
import UIToolkits
import Utilities

extension UIView {
    open func installView(xib: String?) -> UIView? {
        return installView(xib: xib, into: self)
    }

    @objc open func installView(xib: String?, into contentView: UIView?) -> UIView? {
        if let contentView = contentView {
            if let loadedView: UIView = XibLoader.load(from: xib) {
                install(view: loadedView, into: contentView)
                return loadedView
            }
        }
        return nil
    }
}
