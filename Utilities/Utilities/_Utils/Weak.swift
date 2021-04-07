//
//  Weak.swift
//  Utilities
//
//  Created by Qiang Huang on 12/28/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import Foundation

public final class Weak<A: AnyObject> {
    public weak var object: A?
    public init(_ object: A) {
        self.object = object
    }
}
