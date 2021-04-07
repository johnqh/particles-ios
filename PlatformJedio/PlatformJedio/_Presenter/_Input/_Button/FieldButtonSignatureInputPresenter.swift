//
//  FieldButtonSignatureInputPresenter.swift
//  PlatformJedio
//
//  Created by Qiang Huang on 11/28/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import KVOController
import ParticlesKit
import UIAppToolkits
import UIToolkits
import Utilities

@objc open class FieldButtonSignatureInputPresenter: FieldButtonInputPresenter {
    open var imageUrl: String? {
        get {
            return field?.value as? String
        }
        set {
            field?.value = newValue
        }
    }

    override open func updateButton() {
        super.updateButton()
        if let _ = imageUrl {
            if let label = label {
                label.text = "Already Signed"
            } else {
                button?.buttonTitle = "Already Signed"
            }
        } else {
            if let label = label {
                label.text = "Sign Here"
            } else {
                button?.buttonTitle = field?.title ?? "Sign Here"
            }
        }
    }

    @IBAction override func select(_ sender: Any?) {
        let storyboard = "Signature"
        if let signatureViewController = UIViewController.load(storyboard: storyboard) as? SignatureViewController {
            signatureViewController.delegate = self
            let nav = UIViewController.navigation(with: signatureViewController)
            ViewControllerStack.shared?.topmost()?.present(nav, animated: true, completion: nil)
        }
    }
}

extension FieldButtonSignatureInputPresenter: SignatureViewControllerDelegate {
    public func signatureViewController(_ signatureViewController: SignatureViewController, signed: String) {
        imageUrl = signed
        update()
    }
}
