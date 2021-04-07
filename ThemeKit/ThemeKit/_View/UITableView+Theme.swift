//
//  UITableView+Theme.swift
//  ThemeKit
//
//  Created by Qiang Huang on 4/29/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import UIKit

extension UITableView {
    open override func awakeFromNib() {
        super.awakeFromNib()
        setupTheme()
    }

    open override func setupTheme() {
        theme = ThemeManager.shared
    }

    open override func themeChanged(firstTime: Bool) {
        super.themeChanged(firstTime: firstTime)
        if !firstTime {
            beginUpdates()
            endUpdates()
        }
    }
}
