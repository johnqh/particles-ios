//
//  FieldButtonTextInputPresenter.swift
//  PlatformJedio
//
//  Created by Qiang Huang on 11/28/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import JedioKit
import KVOController
import ParticlesKit
import UIToolkits
import Utilities

@objc open class FieldButtonTextInputPresenter: FieldButtonInputPresenter {
    @IBInspectable public var longText: Bool = false
    var options: [[String: Any]]?
    override open var model: ModelObjectProtocol? {
        didSet {
            if model !== oldValue {
                options = field?.options
                update()
            }
        }
    }

    override open func updateButton() {
        super.updateButton()
        let text = self.text(for: field?.value as? String, options: options)
        if let label = label {
            label.text = text
            button?.buttonTitle = nil
        } else {
            button?.buttonTitle = text
        }
    }

    open func text(for value: String?, options: [[String: Any]]?) -> String? {
        if let value = value {
            if let options = options {
                if let option = options.first(where: { (option) -> Bool in
                    if let optionValue = option["value"] as? String, value == optionValue {
                        return true
                    }
                    return false
                }) {
                    return option["text"] as? String ?? "Select"
                }
            } else {
                return value
            }
        }
        return "Select"
    }

    @IBAction override func select(_ sender: Any?) {
        if options?.count ?? 0 > 0 {
            FieldSelectionViewController.select(input: model as? FieldInput)
        } else {
            if longText {
                NoteViewController.note(delegate: self, text: field?.text)
            } else {
                UIAlertController.prompt(title: field?.title, message: nil, text: field?.value as? String, placeholder: nil) { [weak self] text, successful in
                    if successful {
                        self?.field?.value = text
                        self?.updateButton()
                    }
                }
            }
        }
    }
}

extension FieldButtonTextInputPresenter: NoteViewControllerDelegate {
    public func entered(_: NoteViewController, note: String?) {
        field?.value = note
        update()
    }
}
