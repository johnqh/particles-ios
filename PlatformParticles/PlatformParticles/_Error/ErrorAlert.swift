//
//  ErrorAlert.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 9/9/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import ParticlesKit
import UIToolkits
import Utilities

public class ErrorAlert: NSObject, ErrorInfoProtocol {
    public func info(title: String?, message: String?, type: EInfoType?, error: Error?, time: Double?, actions: [ErrorAction]?) {
        if let prompter = PrompterFactory.shared?.prompter() {
            prompter.set(title: title, message: self.message(message: message, error: error), style: .error)
            var promptActions = [PrompterAction]()
            if let actions = actions {
                for action in actions {
                    promptActions.append(PrompterAction(title: action.text, style: .normal, selection: {
                        action.handler()
                    }))
                }
                promptActions.append(PrompterAction.cancel())
            } else {
                promptActions.append(PrompterAction.cancel(title: "OK"))
            }
            prompter.prompt(promptActions)
        }
    }

    public func clear() {
    }
}
