//
//  LocalizationBuffer.swift
//  Utilities
//
//  Created by Qiang Huang on 11/24/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import Foundation

public protocol LocalizerBufferProtocol {
    func localize(_ text: String?, to: String?)
}

public class LocalizerBuffer {
    public static var shared: LocalizerBufferProtocol?
}

public class DebugLocalizer: NSObject, LocalizerBufferProtocol {
    private var backgroundToken: NotificationToken?
    private var strings: [String: String] = [:]
    public func localize(_ text: String?, to: String?) {
        if let text = text?.trim() {
            strings[text] = to ?? text
        }
    }

    public override init() {
        super.init()
        backgroundToken = NotificationCenter.default.observe(notification: UIApplication.didEnterBackgroundNotification, do: { [weak self] _ in
            self?.write()
        })
    }

    private func write() {
        if let localized = Directory.document?.stringByAppendingPathComponent(path: "Localizable.strings") {
            File.delete(localized)
            let mutable = NSMutableString()
            let keys = strings.keys.sorted()
            for key in keys {
                let value = strings[key] ?? key
                mutable.append("\"\(key)\" = \"\(value)\";\n")
            }
            do {
                try mutable.write(toFile: localized, atomically: true, encoding: String.Encoding.utf8.rawValue)
            } catch {
                // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
            }
        }
    }
}
