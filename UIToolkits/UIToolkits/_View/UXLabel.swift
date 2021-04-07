//
//  UXLabel.swift
//  UIToolkits
//
//  Created by Qiang Huang on 1/19/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import UIKit
import Utilities

open class UXLabel: UILabel {
    @IBInspectable public var italic: Bool = false

    open override func awakeFromNib() {
        super.awakeFromNib()
        if italic {
            if let font = self.font {
                self.font = font.italic()
            }
        }
    }
}
