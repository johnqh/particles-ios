//
//  PanelErrorAlert.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 7/11/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import ParticlesKit
import UIToolkits
import Utilities

@objc public class PanelErrorAlert: NSObject, ErrorInfoProtocol {
    @IBInspectable public var infoColor: UIColor?
    @IBInspectable public var errorColor: UIColor?
    @IBInspectable public var warningColor: UIColor?
    @IBInspectable public var successColor: UIColor?
    @IBInspectable public var infoLabelColor: UIColor?
    @IBInspectable public var errorLabelColor: UIColor?
    @IBInspectable public var warningLabelColor: UIColor?
    @IBInspectable public var successLabelColor: UIColor?

    private lazy var infoIcon: UIImage? = {
        UIImage.named("alert_ok", bundles: Bundle.particles)
    }()

    private lazy var errorIcon: UIImage? = {
        UIImage.named("alert_error", bundles: Bundle.particles)
    }()

    private lazy var warningIcon: UIImage? = {
        UIImage.named("alert_error", bundles: Bundle.particles)
    }()

    private lazy var successIcon: UIImage? = {
        UIImage.named("alert_ok", bundles: Bundle.particles)
    }()

    @IBOutlet public var view: UIView? {
        didSet {
            if view !== oldValue {
                if let view = view {
                    let tap = UITapGestureRecognizer(target: self, action: #selector(tap(tapGesture:)))
                    view.addGestureRecognizer(tap)
                }
                updateShowing(animated: false)
            }
        }
    }

    @IBOutlet @objc public dynamic var backgroundViews: [UIView]?

    @IBOutlet public var spinner: WaitProtocol?
    @IBOutlet public var icon: UIImageView?
    @IBOutlet public var text: LabelProtocol?
    @IBOutlet public var message: LabelProtocol?
    @IBOutlet public var button: UIButton? {
        didSet {
            if button !== oldValue {
                oldValue?.removeTarget()
                button?.addTarget(self, action: #selector(handle(_:)))
            }
        }
    }

    @IBOutlet public var buttonConstraint: NSLayoutConstraint?

    public var handler: ErrorActionHandler?

    public var showing: Bool = false {
        didSet {
            if showing != oldValue {
                updateShowing(animated: true)
            }
        }
    }

    public var timer: Timer? {
        didSet {
            if timer !== oldValue {
                oldValue?.invalidate()
            }
        }
    }

    public var panelColor: UIColor? {
        didSet {
            if panelColor !== oldValue {
                if let backgroundViews = backgroundViews {
                    for view in backgroundViews {
                        view.backgroundColor = panelColor
                    }
                }
            }
        }
    }

    public var labelColor: UIColor? {
        didSet {
//            if labelColor !== oldValue {
            text?.textColor = labelColor
            message?.textColor = labelColor
            icon?.tintColor = labelColor
//            }
        }
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        updateShowing(animated: false)
    }

    @objc open func tap(tapGesture: UITapGestureRecognizer) {
        timer = nil
        showing = false
    }

    public func updateShowing(animated: Bool) {
        if showing {
            if animated {
                view?.visible = false
                view?.layoutIfNeeded()
                view?.alpha = 0
                view?.visible = true
                UIView.animate(withDuration: UIView.defaultAnimationDuration) { [weak self] in
                    self?.view?.alpha = 1.0
                }
            } else {
                view?.visible = true
                view?.alpha = 1.0
            }
        } else {
            if animated {
                view?.visible = true
                UIView.animate(withDuration: UIView.defaultAnimationDuration, animations: { [weak self] in
                    self?.view?.alpha = 0.0
                }) { [weak self] _ in
                    self?.view?.visible = false
                }
            } else {
                view?.visible = false
                view?.alpha = 0.0
            }
            timer = nil
        }
    }

    public func info(title: String?, message: String?, type: EInfoType?, error: Error?, time: Double?, actions: [ErrorAction]?) {
        UIView.animate(withDuration: UIView.defaultAnimationDuration) {
            self.display(title: title, message: message, type: type, error: error)
            self.timer = nil
            if let actions = actions {
                if let action = actions.first {
                    self.button?.buttonTitle = action.text
                    self.handler = action.handler
                    self.button?.visible = true
                    self.buttonConstraint?.priority = UILayoutPriority(rawValue: 751)
                } else {
                    self.button?.visible = false
                    self.buttonConstraint?.priority = UILayoutPriority(rawValue: 749)
                }
            } else {
                self.button?.visible = false
                self.buttonConstraint?.priority = UILayoutPriority(rawValue: 749)
            }
            if let time = time, type != .wait {
                self.timer = Timer.scheduledTimer(withTimeInterval: time, repeats: false, block: { [weak self] _ in
                    self?.clear()
                })
            }
        }
    }

    public func display(title: String?, message: String?, type: EInfoType?, error: Error?) {
        let type = self.type(type: type, error: error)
        panelColor = color(type: type)
        labelColor = labelColor(type: type)
        switch type {
        case .wait:
            icon?.visible = false
            spinner?.visible = true
            spinner?.waiting = true

        default:
            spinner?.waiting = false
            spinner?.visible = false
            icon?.visible = true
            icon?.image = image(type: type)
        }
        text?.text = title

        self.message?.text = self.message(message: message, error: error)
        showing = true
    }

    public func labelColor(type: EInfoType) -> UIColor {
        switch type {
        case .error:
            return errorLabelColor ?? UIColor.white

        case .warning:
            return warningLabelColor ?? UIColor.white

        case .success:
            return successLabelColor ?? UIColor.white

        case .info:
            fallthrough
        case .wait:
            fallthrough
        default:
            return infoLabelColor ?? UIColor.darkGray
        }
    }

    public func color(type: EInfoType) -> UIColor {
        switch type {
        case .error:
            return errorColor ?? UIColor.red

        case .warning:
            return warningColor ?? UIColor.orange

        case .success:
            return successColor ?? UIColor.green

        case .info:
            fallthrough
        case .wait:
            fallthrough
        default:
            return infoColor ?? UIColor.white
        }
    }

    public func image(type: EInfoType) -> UIImage? {
        switch type {
        case .error:
            return errorIcon

        case .warning:
            return warningIcon

        case .success:
            return successIcon

        case .info:
            fallthrough
        case .wait:
            fallthrough
        default:
            return infoIcon
        }
    }

    @IBAction func handle(_ sender: Any?) {
        if let handler = handler {
            handler()
            showing = false
        }
    }

    public func clear() {
        showing = false
        timer = nil
    }
}
