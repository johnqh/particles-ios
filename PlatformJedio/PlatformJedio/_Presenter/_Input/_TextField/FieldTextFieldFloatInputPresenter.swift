//
//  FieldTextFieldTextInputPresenter.swift
//  FieldPresenterLib
//
//  Created by Qiang Huang on 10/21/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import UIKit
import Utilities

@objc open class FieldTextFieldFloatInputPresenter: FieldTextFieldInputPresenter {
    private var float: Float? {
        get { return field?.float }
        set { field?.float = newValue }
    }

    override open func update() {
        super.update()
        if let float = float {
            textField?.text = String(float)
        } else {
            textField?.text = nil
        }
    }

    override open func save() {
        if let floatValue = parser.asNumber(textField?.text)?.floatValue {
            float = floatValue
        } else {
            float = nil
        }
    }
}
