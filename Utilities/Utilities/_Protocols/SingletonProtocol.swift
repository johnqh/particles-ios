//
//  SingletonProtocol.swift
//  Utilities
//
//  Created by Qiang Huang on 11/2/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import Foundation

public protocol SingletonProtocol: NSObjectProtocol {
    static var shared: Self { get }
}

public protocol InjectionProtocol: NSObjectProtocol {
    static var shared: Self? { get }
}
