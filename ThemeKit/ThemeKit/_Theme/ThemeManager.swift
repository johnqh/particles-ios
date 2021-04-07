//
//  ThemeManager.swift
//  ThemeKit
//
//  Created by Qiang Huang on 1/1/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import UIToolkits
import Utilities

@objc open class ThemeManager: NSObject {
    var indexTag: String {
        let className = String(describing: type(of: self))
        return "\(className).index"
    }

    @objc public dynamic var index: Int {
        get {
            return UserDefaults.standard.integer(forKey: indexTag)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: indexTag)
            current = theme(at: index)
        }
    }

    @objc public dynamic var themes: [UITheme]?
    @objc public dynamic var current: UITheme?

    @objc public static var shared: ThemeManager?

    @objc public static func load(bundles: [Bundle]) -> ThemeManager {
        let themeManager = ThemeManager()
        for bundle in bundles {
            themeManager.load(bundle: bundle)
        }
        return themeManager
    }

    @objc public static func load(bundle: Bundle) -> ThemeManager {
        let themeManager = ThemeManager()
        themeManager.load(bundle: bundle)
        return themeManager
    }

    private func load(bundle: Bundle) {
        if themes == nil {
            themes = []
        }
        // look for a theme folder
        let bundlePath = bundle.bundlePath
        if let pathes = Directory.files(in: bundlePath, fileExtension: "nib") {
            // compiled XIB files
            for path in pathes {
                let file = path.lastPathComponent
                if file.hasPrefix("Theme_") {
                    let name = file.stringByDeletingPathExtension
                    if let elements = bundle.loadNibNamed(name, owner: nil, options: nil) {
                        let theme: UITheme = elements.first { (element) -> Bool in
                            element is UITheme
                        } as? UITheme ?? UITheme()
                        theme.load(elements: elements)
                        themes?.append(theme)
                    }
                }
            }
        }
        if current == nil {
            current = theme(at: index)
        }
    }

    private func theme(at index: Int) -> UITheme? {
        if index >= 0 && index < (themes?.count ?? 0) {
            return themes?[index]
        } else {
            return nil
        }
    }

    @objc open func apply(to view: UIView?) {
        if let view = view, let current = current {
            current.apply(to: view)
        }
    }
}
