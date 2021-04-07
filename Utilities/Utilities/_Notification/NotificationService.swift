//
//  NotificationService.swift
//  Utilities
//
//  Created by Qiang Huang on 7/18/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import Foundation

@objc public protocol NotificationHandlerProtocol: NSObjectProtocol {
    @objc var authorization: NotificationPermission? { get set }

    func request()
    func present(message: [AnyHashable: Any])
    func receive(message: [AnyHashable: Any]) -> Bool
}

public class NotificationService: NSObject {
    public static var shared: NotificationHandlerProtocol? {
        didSet {
            shared?.authorization = NotificationPermission.shared
        }
    }
}

@objc open class NotificationHandler: NSObject, NotificationHandlerProtocol {
    @objc open dynamic var authorization: NotificationPermission? {
        didSet {
            changeObservation(from: oldValue, to: authorization, keyPath: #keyPath(PrivacyPermission.authorization)) { [weak self] _, _, _ in
                if let self = self {
                    if let permission = self.authorization?.authorization {
                        self.permission = permission
                    }
                }
            }
        }
    }

    @objc open dynamic var permission: EPrivacyPermission = .notDetermined {
        didSet {
            if permission != oldValue {
                switch permission {
                case .authorized:
                    request()

                default:
                    break
                }
            }
        }
    }

    @objc open dynamic var token: String? {
        didSet {
            if token != oldValue {
            }
        }
    }

    open func request() {
    }

    open func present(message: [AnyHashable: Any]) {
    }

    open func receive(message: [AnyHashable: Any]) -> Bool {
        return false
    }
}

open class NotificationUserAssociation: NSObject, AuthProviderAttachmentProtocol {
    public static var shared: NotificationUserAssociation?

    private let userIdentifierTag = "NotificationHandler.userIdentifier"
    private let deviceTokenTag = "NotificationHandler.deviceToken.2"

    @objc open dynamic var userIdentifier: String? {
        didSet {
            if userIdentifier != oldValue {
                dissociate(deviceToken: deviceToken, from: oldValue, userChanged: true)
                associate(deviceToken: deviceToken, with: userIdentifier)
                UserDefaults.standard.set(userIdentifier, forKey: userIdentifierTag)
            }
        }
    }

    @objc open dynamic var deviceToken: String? {
        didSet {
            if deviceToken != oldValue {
                dissociate(deviceToken: oldValue, from: userIdentifier, userChanged: false)
                associate(deviceToken: deviceToken, with: userIdentifier)
                UserDefaults.standard.set(deviceToken, forKey: deviceTokenTag)
            }
        }
    }

    override public init() {
        super.init()
        userIdentifier = UserDefaults.standard.string(forKey: userIdentifierTag)?.trim()
        deviceToken = UserDefaults.standard.string(forKey: deviceTokenTag)?.trim()
    }

    open func dissociate(deviceToken: String?, from userIdentifier: String?, userChanged: Bool) {
        if !userChanged {
            reallyDisassociate(deviceToken: deviceToken, from: userIdentifier, completion: nil)
        }
    }

    private var associateDebouncer: Debouncer = Debouncer()

    open func associate(deviceToken: String?, with userIdentifier: String?) {
        let handler = associateDebouncer.debounce()
        handler?.run({ [weak self] in
            self?.reallyAssociate(deviceToken: deviceToken, with: userIdentifier)
        }, delay: 0.1)
    }

    open func reallyAssociate(deviceToken: String?, with userIdentifier: String?) {
        if let deviceToken = deviceToken, let userIdentifier = userIdentifier {
            Console.shared.log("associate \(deviceToken) with user \(userIdentifier)")
        }
    }

    open func beforeLogin(completion: @escaping AuthAttachmentCompletionBlock) {
        completion(true)
    }

    open func afterLogin() {
        associate(deviceToken: deviceToken, with: userIdentifier)
    }

    open func beforeLogout(token: String, completion: @escaping AuthAttachmentCompletionBlock) {
        completion(true)
        reallyDisassociate(deviceToken: deviceToken, from: token, completion: completion)
    }

    open func afterLogout() {
    }

    open func reallyDisassociate(deviceToken: String?, from userIndentifier: String?, completion: AuthAttachmentCompletionBlock?) {
        if let deviceToken = deviceToken, let userIdentifier = userIdentifier {
            Console.shared.log("dissociate \(deviceToken) from user \(userIdentifier)")
        }
        completion?(true)
    }
}
