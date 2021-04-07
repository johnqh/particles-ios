//
//  MapFieldLoader.swift
//  PlatformJedio
//
//  Created by Qiang Huang on 8/6/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import JedioKit
import Utilities

open class MapFieldLoader: FieldLoader {
    open override func load() -> [FieldDefinitionGroup]? {
        if let groups = super.load() {
            for group in groups {
                if let definitions = group.definitions {
                    for definition in definitions {
                        if let inputDefinition = definition as? FieldInputDefinition, let options = inputDefinition.options {
                            var modified = [[String: Any]]()
                            for option in options {
                                if let urlString = option["value"] as? String, let url = URL(string: urlString), URLHandler.shared?.canOpenURL(url) ?? false {
                                    modified.append(option)
                                }
                            }
                            inputDefinition.options = modified
                        }
                    }
                }
            }
            return groups
        }
        return nil
    }
}
