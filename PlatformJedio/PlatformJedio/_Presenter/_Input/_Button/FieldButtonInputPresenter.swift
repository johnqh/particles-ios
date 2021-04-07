//
//  FieldButtonInputPresenter.swift
//  PlatformJedio
//
//  Created by Qiang Huang on 11/28/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import KVOController
import ParticlesKit
import UIToolkits
import Utilities

@objc open class FieldButtonInputPresenter: FieldInputPresenter {
    @IBInspectable public var unselectedColor: String?
    @IBInspectable public var selectedColor: String?
    @IBInspectable public var unselectedTextColor: String?
    @IBInspectable public var selectedTextColor: String?
    @IBOutlet open var label: LabelView?
    @IBOutlet open var button: UIButton? {
        didSet {
            if button !== oldValue {
                oldValue?.removeTarget()
                button?.addTarget(self, action: #selector(select(_:)))
            }
        }
    }

    override open func update() {
        super.update()
        button?.bringToFront()
        updateButton()
    }

    open func updateButton() {
        if let _ = field?.value {
            if label != nil {
                if let selectedColor = selectedColor {
                    label?.backgroundColor = ColorPalette.shared.color(system: selectedColor)
                }
                if let selectedTextColor = selectedTextColor {
                    label?.textColor = ColorPalette.shared.color(system: selectedTextColor)
                }
            } else {
                if let selectedColor = selectedColor {
                    button?.backgroundColor = ColorPalette.shared.color(system: selectedColor)
                }
                if let selectedTextColor = selectedTextColor {
                    button?.tintColor = ColorPalette.shared.color(system: selectedTextColor)
                }
            }
        } else {
            if label != nil {
                if let unselectedColor = unselectedColor {
                    label?.backgroundColor = ColorPalette.shared.color(system: unselectedColor)
                }
                if let unselectedTextColor = unselectedTextColor {
                    label?.textColor = ColorPalette.shared.color(system: unselectedTextColor)
                }
            } else {
                if let unselectedColor = unselectedColor {
                    button?.backgroundColor = ColorPalette.shared.color(system: unselectedColor)
                }
                if let unselectedTextColor = unselectedTextColor {
                    button?.tintColor = ColorPalette.shared.color(system: unselectedTextColor)
                }
            }
        }
    }

    @IBAction func select(_ sender: Any?) {
    }
}
