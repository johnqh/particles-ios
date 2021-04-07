//
//  FieldTextViewTextInputPresenter.swift
//  PlatformJedio
//
//  Created by Qiang Huang on 10/21/18.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import UIKit

@objc open class FieldTextViewTextInputPresenter: FieldInputPresenter, UITextViewDelegate {
    @IBOutlet var textView: UITextView? {
        didSet {
            if textView !== oldValue {
                oldValue?.delegate = nil
                textView?.delegate = self
            }
        }
    }

    open var string: String? {
        get { return field?.string }
        set { field?.string = newValue }
    }

    override open func update() {
        super.update()
        textView?.text = string?.localized
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        let string = textView.text.trim()
        if self.string != string {
            self.string = string
        }
    }

    public func textView(_ textView: UITextView, shouldChangeTextIn _: NSRange, replacementText text: String) -> Bool {
        let resultRange = text.rangeOfCharacter(from: CharacterSet.newlines, options: .backwards)
        if text.count == 1 && resultRange != nil {
            textView.resignFirstResponder()
            // Do any additional stuff here
            return false
        }
        return true
    }
}
