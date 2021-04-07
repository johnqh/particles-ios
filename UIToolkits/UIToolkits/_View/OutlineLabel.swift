//
//  OutlineLabel.swift
//  UIToolkits
//
//  Created by Qiang Huang on 8/29/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import UIKit
import Utilities

public class OutlineLabel: UILabel {
    private var _text: String?
    override public var text: String? {
        get {
            return _text
        }
        set {
            _text = newValue
            attributedText = text?.outline(color: textColor)
        }
    }
}
