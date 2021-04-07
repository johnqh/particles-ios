//
//  UIViewController+Embed.swift
//  UIToolkits
//
//  Created by Qiang Huang on 9/12/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import UIKit

extension UIViewController {
    @objc open var intrinsicHeight: NSNumber? {
        return nil
    }

    open func embed(_ viewController: UIViewController?, in view: UIView?) {
        if let viewController = viewController, let view = view {
            viewController.willMove(toParent: self)
//            viewController.view.frame = view.bounds
//            view.addSubview(viewController.view)
            view.install(view: viewController.view, into: view)
            addChild(viewController)
            viewController.didMove(toParent: self)
        }
    }

    open func remove(_ viewController: UIViewController?) {
        if let viewController = viewController {
            viewController.willMove(toParent: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()
        }
    }
}
