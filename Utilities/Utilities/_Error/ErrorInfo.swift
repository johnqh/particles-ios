//
//  ErrorAlert.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 9/9/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import Foundation

public typealias ErrorActionHandler = () -> Void

@objc public class ErrorAction: NSObject {
    public var text: String
    public var handler: ErrorActionHandler

    public init(text: String, handler: @escaping ErrorActionHandler) {
        self.text = text
        self.handler = handler
        super.init()
    }

    @IBAction public func action(_ sender: Any?) {
        handler()
    }
}

@objc public enum EInfoType: Int {
    case info
    case wait
    case error
    case warning
    case success
}

public protocol ErrorInfoProtocol: NSObjectProtocol {
    func info(title: String?, message: String?, type: EInfoType?, error: Error?, time: Double?, actions: [ErrorAction]?)
    func clear()
}

public extension ErrorInfoProtocol {
    func info(title: String?, message: String?, error: Error?) {
        info(title: title, message: message, type: nil, error: error, time: 3.0)
    }

    func info(title: String?, message: String?, error: Error?, time: Double?) {
        info(title: title, message: message, type: nil, error: error, time: time, actions: nil)
    }

    func info(title: String?, message: String?, error: Error?, actions: [ErrorAction]?) {
        info(title: title, message: message, type: nil, error: error, time: 3.0, actions: actions)
    }

    func info(title: String?, message: String?, type: EInfoType?, error: Error?) {
        info(title: title, message: message, type: type, error: error, time: 3.0)
    }

    func info(title: String?, message: String?, type: EInfoType?, error: Error?, time: Double?) {
        info(title: title, message: message, type: type, error: error, time: time, actions: nil)
    }

    func info(title: String?, message: String?, type: EInfoType?, error: Error?, actions: [ErrorAction]?) {
        info(title: title, message: message, type: type, error: error, time: 3.0, actions: actions)
    }

    func type(type: EInfoType?, error: Error?) -> EInfoType {
        if let type = type {
            return type
        } else {
            if let error = error {
                let nsError = error as NSError
                if nsError.code != 0 {
                    return .error
                } else {
                    return .info
                }
            } else {
                return .info
            }
        }
    }

    func message(message: String?, error: Error?) -> String? {
        if let message = message {
            return message
        } else {
            if let error = error {
                let nsError = error as NSError
                var text: String?
                if let description = nsError.userInfo["description"] as? String {
                    text = description
                } else if let error = nsError.userInfo["error"] as? [String: Any] {
                    text = error["msg"] as? String ?? error["message"] as? String
                }
                return text ?? error.localizedDescription
            }
            return nil
        }
    }
}

public class ErrorInfo {
    public static var shared: ErrorInfoProtocol?
}

@objc public class ErrorInfoSwitcher: NSObject {
    public static func switcher(errorInfo: ErrorInfoProtocol) -> ErrorInfoSwitcher {
        let switcher = ErrorInfoSwitcher()
        switcher.errorInfo = errorInfo
        return switcher
    }

    private var errorInfo: ErrorInfoProtocol? {
        didSet {
            if errorInfo !== oldValue {
                previous = ErrorInfo.shared
                ErrorInfo.shared = errorInfo
            }
        }
    }

    private var previous: ErrorInfoProtocol?

    deinit {
        if let previous = previous {
            ErrorInfo.shared = previous
        }
    }
}
