//
//  ObjectPresenterContainerView.swift
//  PresenterLib
//
//  Created by Qiang Huang on 10/10/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import ParticlesKit
import UIKit

public class ObjectPresenterContainerView: UIView, ObjectPresenterProtocol, SelectableProtocol {
    public var xibCache: XibPresenterCache = XibPresenterCache()

    @IBInspectable public var xibMap: String? {
        didSet {
            xibCache.xibMap = xibMap
        }
    }

    @IBOutlet public var presenterView: UIView?

    public var xib: String? {
        didSet {
            if xib != oldValue {
                presenterView?.removeFromSuperview()
                presenterView = installView(xib: xib, into: self)
            }
        }
    }

    public var model: ModelObjectProtocol? {
        get { return (presenterView as? ObjectPresenterView)?.model }
        set {
            xib = xib(object: newValue)
            (presenterView as? ObjectPresenterView)?.model = newValue
        }
    }

    @objc open var selectable: Bool {
        return (presenterView as? ObjectPresenterView)?.selectable ?? false
    }

    open var isSelected: Bool = false {
        didSet {
            if isSelected != oldValue {
                (presenterView as? SelectableProtocol)?.isSelected = isSelected
            }
        }
    }

    public func xib(object: ModelObjectProtocol?) -> String? {
        return xibCache.xib(object: object)
    }
}
