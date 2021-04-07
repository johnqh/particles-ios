//
//  XibJsonFile.swift
//  UIToolkits
//
//  Created by John Huang on 10/10/18.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import Utilities

public class XibJsonFile: NSObject {
    public static var parserOverwrite: Parser?

    public override var parser: Parser {
        return XibJsonFile.parserOverwrite ?? super.parser
    }

    private var xibFiles: [String: Any]?

    public init(fileName: String, bundle: Bundle) {
        super.init()
        xibFiles = JsonLoader.load(bundle: bundle, fileName: fileName) as? [String: Any]
    }

    public init(fileName: String, bundles: [Bundle]) {
        super.init()
        xibFiles = bundles.compactMap({ (bundle) -> [String: Any]? in
            JsonLoader.load(bundle: bundle, fileName: fileName) as? [String: Any]
        }).first
    }

    public func xibFile(object: ModelObjectProtocol?) -> String? {
        let value = xibValue(model: object)
        return xibValue(object: object, value: value)
    }

    func xibValue(model: ModelObjectProtocol?) -> Any? {
        let interactor = model as? (InteractorProtocol)
        var value = xibValue(object: interactor)
        if value == nil {
            let entity = interactor?.entity ?? model
            value = xibValue(object: entity)
        }
        return value
    }

    private func xibValue(object: ModelObjectProtocol?) -> Any? {
        if let xibFiles = self.xibFiles, let object = object as? NSObject {
            let classNames = object.classNames()
            var value: Any?
            for className in classNames {
                value = xibFiles[className.pathExtension] ?? xibFiles[className] // className contains module name
                if value != nil {
                    break
                }
            }
            return parser.conditioned(value)
        }
        return nil
    }

    private func xibValue(object: ModelObjectProtocol?, value: Any?) -> String? {
        if let string = value as? String {
            return string
        } else if let dictionary = value as? [String: Any] {
            var string: String?
            var defaultString: String?
            for (key, value) in dictionary {
                if key == "default" {
                    defaultString = value as? String
                } else if let dictionary = value as? [String: Any], let object = object as? (NSObject & ModelObjectProtocol) {
                    if let keyPathValue = parser.asString(object.value(forKey: key)) {
                        string = xibValue(object: object, value: dictionary[keyPathValue])
                        if string != nil {
                            break
                        }
                    }
                }
            }
            if string == nil {
                string = defaultString
            }
            return string
        }
        return nil
    }
}
