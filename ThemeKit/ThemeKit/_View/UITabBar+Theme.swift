//
//  UITabbar+Theme.swift
//  ThemeKit
//
//  Created by Qiang Huang on 1/1/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import UIKit

extension UITabBar {
    open override func applyTemplate(_ templateView: UIView) {
        if let templateTabBar = templateView as? UITabBar {
            super.applyTemplate(templateView)
            barStyle = templateTabBar.barStyle
            isTranslucent = templateTabBar.isTranslucent
            barTintColor = templateTabBar.barTintColor
        }
    }
}
