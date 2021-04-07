//
//  RoutingiOSMap.swift
//  PlatformRouting
//
//  Created by Qiang Huang on 10/12/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import RoutingKit
import Utilities

extension RoutingMap {
    public var isStoryboard: Bool {
        return destination.ends(with: "storyboard")
    }

    public var isXib: Bool {
        return destination.ends(with: "xib")
    }

    public var storyboard: String? {
        if isStoryboard {
            return destination.stringByDeletingPathExtension
        } else {
            return nil
        }
    }

    public var xib: String? {
        if isXib {
            return destination.stringByDeletingPathExtension
        } else {
            return nil
        }
    }
}
