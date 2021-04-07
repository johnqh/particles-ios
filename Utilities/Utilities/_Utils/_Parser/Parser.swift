//
//  Any+Types.swift
//  Utilities
//
//  Created by John Huang on 10/8/18.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import Foundation

@objc open class Parser: NSObject {
    @objc fileprivate static var standard: Parser = {
        Parser()
    }()

    @objc open func conditioned(_ data: Any?) -> Any? {
        return data
    }

    @objc open func asString(_ data: Any?) -> String? {
        var temp: String?
        if let date = data as? Date {
            temp = date.localDateString
        } else if let string = data as? NSString {
            temp = string as String
        } else if let string = data as? String {
            temp = string
        } else if let convertible = data as? CustomStringConvertible {
            temp = convertible.description
        }
        if temp == "<null>" {
            temp = nil
        }
        return temp?.trim()
    }

    @objc open func asValidString(_ data: Any?) -> String? {
        if let string = asString(data), string != "" {
            return string
        }
        return nil
    }

    @objc open func asStrings(_ data: Any?) -> [String]? {
        if let strings = data as? [String] {
            return strings
        } else if let string = asString(data) {
            let lines = string.components(separatedBy: ",")
            var strings = [String]()
            for line in lines {
                if let trimmed = line.trim() {
                    strings.append(trimmed)
                }
            }
            return strings
        }
        return nil
    }

    @objc open func asNumber(_ data: Any?) -> NSNumber? {
        if let number = data as? NSNumber {
            return number
        } else if let int = data as? Int {
            return NSNumber(integerLiteral: int)
        } else if let float = data as? Float {
            return NSNumber(floatLiteral: Double(float) + 0.5)
        } else if let double = data as? Double {
            return NSNumber(floatLiteral: double + 0.5)
        } else if let string = data as? String {
            if let int = Int(string) {
                return NSNumber(integerLiteral: int)
            } else if let float = Double(string) {
                return NSNumber(floatLiteral: float)
            }
        }
        return nil
    }

    @objc open func asBoolean(_ data: Any?) -> NSNumber? {
        if let string = (data as? String)?.lowercased() {
            if string == "y" || string == "1" || string == "true" || string == "yes" || string == "on" {
                return true
            } else if string == "n" || string == "0" || string == "false" || string == "no" || string == "off" {
                return false
            }
        } else if let boolean = data as? Bool {
            return NSNumber(value: boolean)
        } else if let boolean = data as? Int {
            return NSNumber(value: boolean)
        }
        return nil
    }

    @objc open func asDictionary(_ data: Any?) -> [String: Any]? {
        return data as? [String: Any]
    }

    @objc open func asArray(_ data: Any?) -> [Any]? {
        if let data = data {
            if data is Dictionary<AnyHashable, Any> {
                return nil
            } else if let data = data as? [Any] {
                return data
            } else {
                return [data]
            }
        }
        return nil
    }

    open func asInt(_ data: Any?) -> Int? {
        if let number = data as? NSNumber {
            return number.intValue
        } else if let int = data as? Int {
            return int
        } else if let float = data as? Float {
            return Int(float + 0.5)
        } else if let double = data as? Double {
            return Int(double + 0.5)
        } else if let string = data as? String {
            if let int = Int(string) {
                return int
            } else if let float = Double(string), !float.isInfinite, !float.isNaN, float < Double(Int.max), float > Double(Int.min) {
                return Int(float)
            }
        } else if let date = data as? Date {
            return Int(date.timeIntervalSince1970 * 1000)
        }
        return nil
    }

    open func asDate(_ data: Any?) -> Date? {
        if let date = data as? Date {
            return date
        } else if let timeSince1970 = asInt(data) {
            return Date(timeIntervalSince1970: TimeInterval(timeSince1970 / 1000))
        }
        return nil
    }
    

    @objc open func asURL(_ data: Any?) -> URL? {
        if let string = self.asString(data) {
            return URL(string: string)
        }
        return nil
    }
}

extension NSObject {
    @objc open var parser: Parser {
        return Parser.standard
    }
}
