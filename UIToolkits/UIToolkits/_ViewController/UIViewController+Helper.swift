//
//  UIViewController+Helper.swift
//  UIToolkits
//
//  Created by Qiang Huang on 10/23/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import UIKit

extension UIViewController {
    open var topParent: UIViewController {
        if let parent = parent {
            return parent.topParent
        } else {
            return self
        }
    }

    open func halfParent(of viewController: UIViewController) -> UIViewController? {
        if ((self as AnyObject) as? UIViewControllerHalfProtocol)?.floatingManager?.halved == viewController {
            return self
        } else {
            return parent?.halfParent(of: viewController)
        }
    }

    @IBAction open func dismiss(_ sender: Any?) {
        if let presenting = self.presentingViewController ?? self.navigationController?.presentingViewController {
            presenting.dismiss(animated: true, completion: nil)
        } else {
            let halfParent = parent?.halfParent(of: self)
            if halfParent !== self {
                ((halfParent as AnyObject) as? UIViewControllerHalfProtocol)?.dismiss(self, animated: true)
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }
}
