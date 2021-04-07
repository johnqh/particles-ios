//
//  UITextView+Theme.swift
//  ThemeKit
//
//  Created by Qiang Huang on 1/1/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import UIKit

extension UITextView {
    open override func applyTemplate(_ templateView: UIView) {
        if let templateTextView = templateView as? UITextView {
            super.applyTemplate(templateView)
            font = templateTextView.font
            textColor = templateTextView.textColor
        }
    }
}
