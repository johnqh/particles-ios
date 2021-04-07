//
//  FieldPickerTextInputPresenter.swift
//  PlatformJedio
//
//  Created by Qiang Huang on 8/20/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import UIToolkits
import Utilities

@objc open class FieldPickerTextInputPresenter: FieldTextFieldTextInputPresenter {
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) { [weak self] in
            self?.promptForOptions()
        }
        return true
    }

    private func promptForOptions() {
        if let options = field?.fieldInput?.options {
            if let prompter = PrompterFactory.shared?.prompter() {
                prompter.style = .selection

                var actions = [PrompterAction]()
                for option in options {
                    if let text = parser.asString(option["text"]), let value = parser.asString(option["value"]) {
                        let action = PrompterAction(title: text, style: .normal, enabled: true) { [weak self] in
                            if let self = self {
                                self.string = value
                                self.update()
                            }
                        }
                        actions.append(action)
                    }
                }
                actions.append(PrompterAction.cancel())
                prompter.prompt(actions)
            }
        }
    }
}
