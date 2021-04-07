//
//  FieldTextFieldTextInputPresenter.swift
//  FieldPresenterLib
//
//  Created by Qiang Huang on 10/21/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import UIKit
import Utilities

@objc open class FieldTextFieldIntInputPresenter: FieldTextFieldInputPresenter {
    private var int: Int? {
        get { return field?.int }
        set { field?.int = newValue }
    }

    override open func update() {
        super.update()
        if let int = int {
            textField?.text = String(int)
        } else {
            textField?.text = nil
        }
    }

    override open func save() {
        if let intValue = parser.asNumber(textField?.text)?.intValue {
            if int != intValue {
                int = intValue
            }
        } else {
            if int != nil {
                int = nil
            }
        }
    }
}
