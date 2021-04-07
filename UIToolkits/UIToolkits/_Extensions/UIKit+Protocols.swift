//
//  UILabel+Protocol.swift
//  UIToolkits
//
//  Created by Qiang Huang on 12/11/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import UIKit

extension UIView: ViewProtocol {
    public var visible: Bool {
        get { return !isHidden }
        set {
            isHidden = !newValue
        }
    }
}

extension UIActivityIndicatorView: SpinnerProtocol {
    public var spinning: Bool {
        get { return isAnimating }
        set {
            if newValue {
                startAnimating()
            } else {
                stopAnimating()
            }
        }
    }
}

extension UILabel: LabelProtocol {
    public func formatUrl(text: String?) -> URL? {
        if let text = text {
            if let ranges = text.detectHttpUrl() {
                let styledText = NSMutableAttributedString(string: text)

                for range in ranges {
                    styledText.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
                    styledText.addAttribute(NSAttributedString.Key.foregroundColor, value: ColorPalette.shared.color(system: "blue") ?? UIColor.blue, range: range)
                }
                self.text = nil
                attributedText = styledText
                if let first = ranges.first, let range = Range(first, in: text) {
                    let urlString = String(text[range])
                    return URL(string: urlString)
                }
                return nil
            } else {
                attributedText = nil
                self.text = text
                return nil
            }
        } else {
            attributedText = nil
            self.text = nil
            return nil
        }
    }
}

extension UITextField: LabelProtocol {
    public func formatUrl(text: String?) -> URL? {
        if let text = text, let ranges = text.detectHttpUrl() {
            let styledText = NSMutableAttributedString(string: text)

            for range in ranges {
                styledText.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            }
            attributedText = styledText
            if let first = ranges.first, let range = Range(first, in: text) {
                let urlString = String(text[range])
                return URL(string: urlString)
            }
            return nil
        } else {
            self.text = text
            return nil
        }
    }
}

extension UIImageView: ImageViewProtocol {
}

extension UIControl: ControlProtocol {
    public func removeTarget() {
        removeTarget(nil, action: nil, for: .allEvents)
    }

    public func addTarget(_ target: AnyObject?, action: Selector) {
        removeTarget()
        addTarget(target, action: action, for: .touchUpInside)
    }

    public func add(target: AnyObject?, action: Selector, for controlEvents: UIControl.Event) {
        addTarget(target, action: action, for: controlEvents)
    }
}

extension UIButton: ButtonProtocol {
    public var buttonTitle: String? {
        get {
            return title(for: .normal)
        }
        set {
            setTitle(newValue, for: .normal)
        }
    }

    public var buttonImage: UIImage? {
        get {
            return image(for: .normal)
        }
        set {
            setImage(newValue, for: .normal)
        }
    }

    public var buttonChecked: Bool {
        get {
            return isSelected
        }
        set {
            isSelected = newValue
        }
    }
}

extension UIBarButtonItem: ButtonProtocol {
    public var backgroundColor: NativeColor! {
        get {
            return UIColor.clear
        }
        set {
        }
    }

    public var buttonTitle: String? {
        get {
            return title
        }
        set {
            title = newValue
        }
    }

    public var buttonImage: NativeImage? {
        get {
            return image
        }
        set {
            image = newValue
        }
    }

    public var buttonChecked: Bool {
        get {
            return checked
        }
        set {
            checked = newValue
        }
    }

    public var frame: CGRect {
        get {
            return CGRect()
        }
        set {
        }
    }

    public var visible: Bool {
        get {
            return isEnabled
        }
        set {
            isEnabled = newValue
        }
    }

    public var checked: Bool {
        get {
            return tintColor == UIColor.blue
        }
        set {
            tintColor = newValue ? UIColor.blue : UIColor.darkGray
        }
    }

    public func removeTarget() {
        target = nil
        action = nil
    }

    public func addTarget(_ target: AnyObject?, action: Selector) {
        self.target = target
        self.action = action
    }

    public func add(target: AnyObject?, action: Selector, for controlEvents: UIControl.Event) {
        addTarget(target, action: action)
    }
}

extension UISegmentedControl: SegmentedProtocol {
    public var selectedIndex: Int {
        get {
            return selectedSegmentIndex
        }
        set {
            selectedSegmentIndex = newValue
        }
    }

    public static func segments(with titles: [String]) -> SegmentedProtocol {
        let segments = UISegmentedControl()
        for title in titles {
            segments.insertSegment(withTitle: title, at: segments.numberOfSegments, animated: false)
        }
        return segments
    }

    override public func addTarget(_ target: AnyObject?, action: Selector) {
        removeTarget()
        addTarget(target, action: action, for: .valueChanged)
    }
}
