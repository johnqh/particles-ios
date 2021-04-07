//
//  String+Styles.swift
//  UIToolkits
//
//  Created by Qiang Huang on 8/29/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import Foundation
import UIKit

public extension String {
    func outline(color: UIColor) -> NSAttributedString? {
        let outlineTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.white,
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.strokeWidth: -1.0,
        ]
        return NSAttributedString(string: self, attributes: outlineTextAttributes)
    }
}
