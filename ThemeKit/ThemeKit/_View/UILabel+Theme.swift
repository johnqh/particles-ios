//
//  UILabel+Theme.swift
//  ThemeKit
//
//  Created by Qiang Huang on 1/1/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import UIKit

extension UILabel {
    open override func applyTemplate(_ templateView: UIView) {
        if let templateLabel = templateView as? UILabel {
            super.applyTemplate(templateView)
            font = templateLabel.font
            textColor = templateLabel.textColor
        }
    }
}
