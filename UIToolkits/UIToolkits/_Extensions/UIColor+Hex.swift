//
//  UIColor+Hex.swift
//  UIToolkits
//
//  Created by Qiang Huang on 7/29/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import UIKit
import Utilities

extension UIColor {
    public static func color(hex: String) -> UIColor? {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if cString.count == 6 {
            var rgbValue: UInt32 = 0
            if Scanner(string: cString).scanHexInt32(&rgbValue) {
                return UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0, blue: CGFloat(rgbValue & 0x0000FF) / 255.0, alpha: CGFloat(1.0)
                )
            }
        }
        return nil
    }
}

extension UIColor {
    public static func color(string: String?) -> UIColor? {
        if let string = string {
            let hash = abs(string.sdbmhash)
            let colorNum = hash % (256 * 256 * 256)
            let red = colorNum >> 16
            let green = (colorNum & 0x00FF00) >> 8
            let blue = (colorNum & 0x0000FF)
            let darkeningFactor = CGFloat(1.25 * 255.0)
            return UIColor(red: CGFloat(red) / darkeningFactor, green: CGFloat(green) / darkeningFactor, blue: CGFloat(blue) / darkeningFactor, alpha: 1.0)
        }
        return nil
    }
}
