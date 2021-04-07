//
//  FieldSwitchInputPresenter.swift
//  FieldPresenterLib
//
//  Created by Qiang Huang on 10/20/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import UIKit

@objc open class FieldSwitchInputPresenter: FieldInputPresenter {
    @IBOutlet open var checkbox: UISwitch? {
        didSet {
            if checkbox !== oldValue {
                oldValue?.removeTarget(self, action: #selector(check(_:)), for: .valueChanged)
                checkbox?.addTarget(self, action: #selector(check(_:)), for: .valueChanged)
            }
        }
    }

    private var checked: Bool? {
        get {
            return field?.checked
        }
        set {
            field?.checked = newValue
        }
    }

    override open func update() {
        super.update()
        checkbox?.isOn = field?.checked ?? false
    }

    @IBAction func check(_ sender: Any?) {
        field?.checked = checkbox?.isOn
    }
}
