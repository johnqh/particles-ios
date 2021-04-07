//
//  UIToolBar+Theme.swift
//  ThemeKit
//
//  Created by Qiang Huang on 1/1/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import UIKit

extension UIToolbar {
    open override func applyTemplate(_ templateView: UIView) {
        if let templateToolbar = templateView as? UIToolbar {
            super.applyTemplate(templateView)
            barStyle = templateToolbar.barStyle
            barTintColor = templateToolbar.barTintColor
        }
    }
}
