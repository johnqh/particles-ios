//
//  BannerErrorAlert.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 1/21/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import AVFoundation
import ParticlesKit
import SwiftMessages
import UIToolkits
import Utilities

public class BannerErrorAlert: NSObject, ErrorInfoProtocol {
    public func configuration(type: EInfoType?, time: Double?) -> SwiftMessages.Config {
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: .statusBar)
        if let time = time {
            config.duration = .seconds(seconds: time)
        } else {
            config.duration = .forever
        }
        return config
    }

    public func info(title: String?, message: String?, type: EInfoType?, error: Error?, time: Double?, actions: [ErrorAction]?) {
        if let messageView = view(title: title, message: message, type: type, error: error) {
            if let actions = actions {
                if actions.count == 1 {
                    messageView.button?.isHidden = false
                    if let action = actions.first {
                        messageView.button?.buttonTitle = action.text
                        messageView.buttonTapHandler = { _ in
                            SwiftMessages.hide()
                            action.action(messageView.button)
                        }
                    }
                } else {
                    for action in actions {
                        let button = UIButton()
                        button.buttonTitle = action.text
                        button.addTarget(action, action: #selector(ErrorAction.action(_:)))
                        messageView.addSubview(button)
                    }
                }
            }
            SwiftMessages.hide()
            let config = configuration(type: type, time: time)
            SwiftMessages.show(config: config, view: messageView)
            if error != nil {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
        }
    }

    private func view(title: String?, message: String?, type: EInfoType?, error: Error?) -> MessageView? {
        let message = self.message(message: message, error: error) ?? error?.localizedDescription
        if title != nil || message != nil {
            let view = MessageView.viewFromNib(layout: .cardView)
            let type = self.type(type: type, error: error)
            switch type {
            case .warning:
                view.configureTheme(.warning)

            case .error:
                view.configureTheme(.error)

            case .success:
                view.configureTheme(.success)

            case .info:
                fallthrough
            case .wait:
                fallthrough
            default:
                view.configureTheme(.info)
            }
            view.configureDropShadow()
            view.configureContent(title: title ?? "", body: message ?? "")
            view.button?.isHidden = true
            return view
        }
        return nil
    }

    public func clear() {
        SwiftMessages.hide()
    }
}
