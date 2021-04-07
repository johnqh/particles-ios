//
//  SimpleLocalNotification.swift
//  RoutingKit
//
//  Created by Qiang Huang on 11/4/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import RoutingKit
import UIKit
import Utilities

public class SimpleLocalNotification: NSObject, LocalNotificationProtocol {
    private var backgroundToken: NotificationToken?
    private var foregroundToken: NotificationToken?
    private var backgroundId: String?

    private var outstandingIds: [String]?

    public var background: LocalNotificationMessage? {
        didSet {
            if background !== oldValue {
                if let backgroundId = backgroundId {
                    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [backgroundId])
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [backgroundId])
                }
                if backgrounded {
                    backgroundId = sending(message: background)
                }
            }
        }
    }

    public var backgrounded: Bool = false {
        didSet {
            if backgrounded != oldValue {
                if backgrounded {
                    sendBackgrounding()
                } else {
                    removeBackgrounding()
                }
            }
        }
    }

    public func sending(message: LocalNotificationMessage?) -> String? {
        if let message = message {
            let content = UNMutableNotificationContent()
            content.title = message.title

            if let subtitle = message.subtitle {
                content.subtitle = subtitle
            }
            if let text = message.text {
                content.body = text
            }
            if let link = message.link {
                content.userInfo = ["data": ["firebase": ["link": link]]]
            }
            content.sound = UNNotificationSound.default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: message.delay ?? 0.5, repeats: false)

            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

            let center = UNUserNotificationCenter.current()
            center.add(request) { error in
                if error != nil {
                    print("error \(String(describing: error))")
                }
            }
            return uuidString
        }
        return nil
    }

    public func send(message: LocalNotificationMessage) {
        if backgrounded, let identifier = sending(message: message) {
            if outstandingIds == nil {
                outstandingIds = [String]()
            }
            outstandingIds?.append(identifier)
        }
    }

    override public init() {
        super.init()
        #if _iOS
            backgroundToken = NotificationCenter.default.observe(notification: UIApplication.didEnterBackgroundNotification, do: { [weak self] _ in
                self?.backgrounded = true
            })

            foregroundToken = NotificationCenter.default.observe(notification: UIApplication.willEnterForegroundNotification, do: { [weak self] _ in
                self?.backgrounded = false
            })
        #endif
    }

    private func sendBackgrounding() {
        backgroundId = sending(message: background)
    }

    private func removeBackgrounding() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        backgroundId = nil
        outstandingIds = nil
    }
}

extension SimpleLocalNotification: NotificationBridgeProtocol {
    public func launched() {
    }

    public func registered(deviceToken: Data) {
    }

    public func failed(error: Error) {
    }

    public func received(userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let routing = userInfo["routing"] as? String {
            Router.shared?.navigate(to: RoutingRequest(url: routing), animated: true, completion: nil)
            completionHandler(.newData)
        } else {
            completionHandler(.noData)
        }
    }
}
