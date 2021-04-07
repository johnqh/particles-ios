//
//  FieldTextFieldTextInputPresenter.swift
//  FieldPresenterLib
//
//  Created by Qiang Huang on 10/21/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import UIKit

@objc open class FieldTextFieldTextInputPresenter: FieldTextFieldInputPresenter {
    open var string: String? {
        get { return field?.string }
        set { field?.string = newValue }
    }

    override open func update() {
        super.update()
        textField?.text = string?.localized
    }

    override open func save() {
        let string = textField?.text?.trim()
        if self.string != string {
            self.string = string
        }
    }
}
