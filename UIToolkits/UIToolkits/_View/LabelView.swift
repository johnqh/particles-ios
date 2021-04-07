//
//  LabelView.swift
//  UIToolkits
//
//  Created by Qiang Huang on 10/14/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import UIKit

@objc open class LabelView: UIView, LabelProtocol {
    public var textColor: NativeColor! {
        get {
            return label?.textColor ?? UIColor.black
        }
        set {
            label?.textColor = newValue
        }
    }

    public var font: NativeFont! {
        get {
            return label?.font ?? UIFont.systemFont(ofSize: 14)
        }
        set {
            label?.font = newValue
        }
    }

    @IBOutlet public var label: UILabel?
    @IBOutlet public var sublabel: UILabel? {
        didSet {
            if sublabel !== oldValue {
                if subtext != nil {
                    sublabel?.text = subtext
                } else {
                    subtext = sublabel?.text
                }
            }
        }
    }

    open var attributedText: NSAttributedString? {
        get {
            return label?.attributedText
        }
        set {
            label?.attributedText = newValue
            updateVisibility()
        }
    }

    open var text: String? {
        get {
            return label?.text
        }
        set {
            label?.text = newValue
            updateVisibility()
        }
    }

    open var subtext: String? {
        didSet {
            if subtext != oldValue {
                sublabel?.text = subtext
            }
        }
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        text = nil
    }

    open func updateVisibility() {
        visible = (label?.text?.trim() != nil)
    }

    public func formatUrl(text: String?) -> URL? {
        let url = label?.formatUrl(text: text)
        updateVisibility()
        return url
    }
}
