//
//  ObjectPresenterContainerView.swift
//  PresenterLib
//
//  Created by John Huang on 10/10/18.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import ParticlesKit
import UIKit

public class ObjectPresenterContainer: UIView, ObjectPresenterProtocol, SelectableProtocol {
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
                (presenterView as? SelectableProtocol)?.isSelected = isSelected
            }
        }
    }

    public var model: ModelObjectProtocol? {
        get { return (presenterView as? ObjectPresenterView)?.model }
        set {
            xib = xib(object: newValue)
            (presenterView as? ObjectPresenterView)?.model = newValue
            (presenterView as? SelectableProtocol)?.isSelected = isSelected
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

    public override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return frame.size
    }

    public func xib(object: ModelObjectProtocol?) -> String? {
        return xibCache.xib(object: object)
    }
}
