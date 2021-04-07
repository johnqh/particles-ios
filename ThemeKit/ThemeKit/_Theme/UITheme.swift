//
//  UITheme.swift
//  ThemeKit
//
//  Created by Qiang Huang on 1/1/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import UIKit

@objc open class UITheme: NSObject {
    @IBInspectable var name: String?
    public var viewByClasses: [String: UIView] = [:]

    public func load(elements: [Any]) {
        for element in elements {
            if let buttonItem = element as? UIBarButtonItem {
                UIBarButtonItem.appearance().setTitleTextAttributes(buttonItem.titleTextAttributes(for: .normal), for: .normal)
                UIBarButtonItem.appearance().setTitleTextAttributes(buttonItem.titleTextAttributes(for: .disabled), for: .disabled)
                UIBarButtonItem.appearance().setTitleTextAttributes(buttonItem.titleTextAttributes(for: .selected), for: .selected)
                UIBarButtonItem.appearance().setTitleTextAttributes(buttonItem.titleTextAttributes(for: .highlighted), for: .highlighted)
                UIBarButtonItem.appearance().setTitleTextAttributes(buttonItem.titleTextAttributes(for: .focused), for: .focused)
            } else if let tabbarItem = element as? UITabBarItem {
                UITabBarItem.appearance().setTitleTextAttributes(tabbarItem.titleTextAttributes(for: .normal), for: .normal)
                UITabBarItem.appearance().setTitleTextAttributes(tabbarItem.titleTextAttributes(for: .disabled), for: .disabled)
                UITabBarItem.appearance().setTitleTextAttributes(tabbarItem.titleTextAttributes(for: .selected), for: .selected)
                UITabBarItem.appearance().setTitleTextAttributes(tabbarItem.titleTextAttributes(for: .highlighted), for: .highlighted)
                UITabBarItem.appearance().setTitleTextAttributes(tabbarItem.titleTextAttributes(for: .focused), for: .focused)
            } else if let navigateBar = element as? UINavigationBar {
                UINavigationBar.appearance().barStyle = navigateBar.barStyle
                UINavigationBar.appearance().barTintColor = navigateBar.barTintColor
                UINavigationBar.appearance().tintAdjustmentMode = navigateBar.tintAdjustmentMode
                UINavigationBar.appearance().tintColor = navigateBar.tintColor
                UINavigationBar.appearance().backgroundColor = navigateBar.backgroundColor
                UINavigationBar.appearance().alpha = navigateBar.alpha
            } else if let toolBar = element as? UIToolbar {
                UIToolbar.appearance().barStyle = toolBar.barStyle
                UIToolbar.appearance().barTintColor = toolBar.barTintColor
                UIToolbar.appearance().tintAdjustmentMode = toolBar.tintAdjustmentMode
                UIToolbar.appearance().tintColor = toolBar.tintColor
                UIToolbar.appearance().backgroundColor = toolBar.backgroundColor
                UIToolbar.appearance().alpha = toolBar.alpha
            } else if let tabBar = element as? UITabBar {
                UITabBar.appearance().barStyle = tabBar.barStyle
                UITabBar.appearance().barTintColor = tabBar.barTintColor
                UITabBar.appearance().tintAdjustmentMode = tabBar.tintAdjustmentMode
                UITabBar.appearance().tintColor = tabBar.tintColor
                tabBar.tintColor = UIColor.red
                UITabBar.appearance().backgroundColor = tabBar.backgroundColor
                UITabBar.appearance().alpha = tabBar.alpha
            } else if let searchBar = element as? UISearchBar {
                UISearchBar.appearance().barStyle = searchBar.barStyle
                UISearchBar.appearance().barTintColor = searchBar.barTintColor
                UISearchBar.appearance().tintAdjustmentMode = searchBar.tintAdjustmentMode
                UISearchBar.appearance().tintColor = searchBar.tintColor
                UISearchBar.appearance().backgroundColor = searchBar.backgroundColor
                UISearchBar.appearance().alpha = searchBar.alpha
            } else if let view = element as? UIView {
                if let styleClass = view.styleClass {
                    viewByClasses[styleClass.lowercased()] = view
                }
            }
        }
    }

    @objc public func view(with styleClass: String?) -> UIView? {
        if let styleClass = styleClass {
            return viewByClasses[styleClass.lowercased()]
        } else {
            return nil
        }
    }

    @objc open func apply(to target: UIView) {
        if let templateview = view(with: target.styleClass) {
            target.applyTemplate(templateview)
        }
    }

    @objc public func font(styleClass: String, size: CGFloat) -> UIFont? {
        return font(styleClass: styleClass)?.withSize(size)
    }

    @objc public func font(styleClass: String) -> UIFont? {
        if let label = view(with: styleClass) as? UILabel {
            return label.font
        }
        return nil
    }
}
