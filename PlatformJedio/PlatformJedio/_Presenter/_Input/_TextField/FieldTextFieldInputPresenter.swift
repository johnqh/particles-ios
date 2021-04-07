//
//  FieldTextFieldInputPresenter.swift
//  FieldPresenterLib
//
//  Created by Qiang Huang on 10/21/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import UIKit

@objc open class FieldTextFieldInputPresenter: FieldInputPresenter, UITextFieldDelegate {
    @IBOutlet public var accessoryToolbar: UIToolbar? {
        didSet {
            if accessoryToolbar !== oldValue {
                textField?.inputAccessoryView = accessoryToolbar
            }
        }
    }

    @IBOutlet var textField: UITextField? {
        didSet {
            if textField !== oldValue {
                oldValue?.delegate = nil
                textField?.delegate = self
                textField?.inputAccessoryView = accessoryToolbar
            }
        }
    }

    override open func update() {
        super.update()
        textField?.placeholder = field?.subtext?.localized
    }

    open func save() {
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        save()
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        save()
        return true
    }

    @IBAction func done(_ sender: Any?) {
        textField?.endEditing(true)
    }
}
