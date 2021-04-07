//
//  NSObject+Association.swift
//  Utilities
//
//  Created by Qiang Huang on 4/27/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import ObjectiveC

public func associatedObject<T>(base: AnyObject, key: UnsafeRawPointer) -> T? {
    return objc_getAssociatedObject(base, key) as? T
}

public func retainObject<T>(base: AnyObject, key: UnsafeRawPointer, value: T?) {
    objc_setAssociatedObject(base, key, value, .OBJC_ASSOCIATION_RETAIN)
}

public func associateObject<T>(base: AnyObject, key: UnsafeRawPointer, value: T?) {
    objc_setAssociatedObject(base, key, value, .OBJC_ASSOCIATION_ASSIGN)
}
