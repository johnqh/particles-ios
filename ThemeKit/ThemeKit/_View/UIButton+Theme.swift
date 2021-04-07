//
//  UIButton+Theme.swift
//  ThemeKit
//
//  Created by Qiang Huang on 9/15/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import UIKit

@objc public extension UIButton {
    override func applyTemplate(_ templateView: UIView) {
        super.applyTemplate(templateView)
        if let templateButton = templateView as? UIButton {
            if let titleColor = templateButton.titleColor(for: .normal) {
                setTitleColor(titleColor, for: .normal)
            }
        }
    }
}
