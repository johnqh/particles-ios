//
//  UIView+Theme.swift
//  ThemeKit
//
//  Created by Qiang Huang on 4/29/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import UIKit
import Utilities

@objc public extension UIView {
    private struct ThemeKeys {
        static var styleClass = "view.styleClass"
        static var theme = "view.theme"
    }

    @IBInspectable var styleClass: String? {
        get {
            return associatedObject(base: self, key: &ThemeKeys.styleClass)
        }
        set {
            retainObject(base: self, key: &ThemeKeys.styleClass, value: newValue)
            setupTheme()
        }
    }

    var theme: ThemeManager? {
        get {
            return associatedObject(base: self, key: &ThemeKeys.theme)
        }
        set {
            let oldValue = theme
            retainObject(base: self, key: &ThemeKeys.theme, value: newValue)
            changeObservation(from: oldValue, to: theme, keyPath: #keyPath(ThemeManager.current), initial: { [weak self] _, _, _ in
                self?.themeChanged(firstTime: true)
            }) { [weak self] _, _, _ in
                self?.themeChanged(firstTime: false)
            }
        }
    }

    @objc func setupTheme() {
        if styleClass != nil {
            theme = ThemeManager.shared
        } else {
            theme = nil
        }
    }

    @objc func themeChanged(firstTime: Bool) {
        theme?.apply(to: self)
    }

    @objc func applyTemplate(_ templateView: UIView) {
        if let backgroundColor = templateView.backgroundColor {
            self.backgroundColor = backgroundColor
        }
        if let borderColor = templateView.borderColor {
            self.borderColor = borderColor
        }
        if borderWidth == 0.0 {
            borderWidth = templateView.borderWidth
        }
        if let tintColor = templateView.tintColor {
            self.tintColor = tintColor
        }
        if corner == 0.0 {
            corner = templateView.corner
        }
        alpha = templateView.alpha
        clipsToBounds = templateView.clipsToBounds
    }
}
