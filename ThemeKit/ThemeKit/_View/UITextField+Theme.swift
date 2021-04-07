//
//  UITextField+Theme.swift
//  ThemeKit
//
//  Created by Qiang Huang on 1/1/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import UIKit

extension UITextField {
    open override func applyTemplate(_ templateView: UIView) {
        if let templateTextField = templateView as? UITextField {
            super.applyTemplate(templateView)
            font = templateTextField.font
            textColor = templateTextField.textColor
        }
    }
}
