//
//  UINavigationBar.swift
//  ThemeKit
//
//  Created by Qiang Huang on 1/1/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import UIKit

extension UINavigationBar {
    open override func applyTemplate(_ templateView: UIView) {
        if let templateNavigationBar = templateView as? UINavigationBar {
            super.applyTemplate(templateView)
            barStyle = templateNavigationBar.barStyle
            barTintColor = templateNavigationBar.barTintColor
        }
    }
}
