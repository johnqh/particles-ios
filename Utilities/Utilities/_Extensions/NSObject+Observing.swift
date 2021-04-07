//
//  NSObject+Observing.swift
//  Utilities
//
//  Created by Qiang Huang on 8/7/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import Foundation
import KVOController

extension NSObject {
    public func changeObservation(from: NSObjectProtocol?, to: NSObjectProtocol?, keyPath: String, initial: FBKVONotificationBlock?, change: FBKVONotificationBlock?) {
        if from !== to {
            kvoController.unobserve(from, keyPath: keyPath)
            if let to = to {
                initial?(self, NSNull(), [:])
                if let change = change {
                    kvoController.observe(to, keyPath: keyPath, options: [.new, .old]) { observer, keyPath, changes in
                        if let old = changes["old"], let new = changes["new"] {
                            if let oldValue = old as? String, let newValue = new as? String {
                                if oldValue != newValue {
                                    change(observer, keyPath, changes)
                                }
                            } else if let oldValue = old as? Date, let newValue = new as? Date {
                                if oldValue != newValue {
                                    change(observer, keyPath, changes)
                                }
                            } else if let oldValue = old as? NSNumber, let newValue = new as? NSNumber {
                                if oldValue != newValue {
                                    change(observer, keyPath, changes)
                                }
                            } else if let oldValue = old as? Bool, let newValue = new as? Bool {
                                if oldValue != newValue {
                                    change(observer, keyPath, changes)
                                }
                            } else if let oldValue = old as? Int, let newValue = new as? Int {
                                if oldValue != newValue {
                                    change(observer, keyPath, changes)
                                }
                            } else if let oldValue = old as? Float, let newValue = new as? Float {
                                if oldValue != newValue {
                                    change(observer, keyPath, changes)
                                }
                            } else if let oldValue = old as? Double, let newValue = new as? Double {
                                if oldValue != newValue {
                                    change(observer, keyPath, changes)
                                }
                            } else if let oldValue = old as? TimeInterval, let newValue = new as? TimeInterval {
                                if oldValue != newValue {
                                    change(observer, keyPath, changes)
                                }
                            } else if let oldObject = old as? NSObject, let newObject = new as? NSObject {
                                if oldObject !== newObject {
                                    change(observer, keyPath, changes)
                                }
                            } else {
                                change(observer, keyPath, changes)
                            }
                        } else {
                            change(observer, keyPath, changes)
                        }
                    }
                }
            } else {
                initial?(self, NSNull(), [:])
            }
        }
    }

    public func changeObservation(from: NSObjectProtocol?, to: NSObjectProtocol?, keyPath: String, block: @escaping FBKVONotificationBlock) {
        changeObservation(from: from, to: to, keyPath: keyPath, initial: block, change: block)
    }

    public func run(_ function: () -> Void, notify: String) {
        willChangeValue(forKey: notify)
        function()
        didChangeValue(forKey: notify)
    }
}
