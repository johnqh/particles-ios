//
//  CredentialsProvider.swift
//  ParticlesKit
//
//  Created by John Huang on 7/16/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import Utilities

open class JsonCredentialsProvider: NSObject {
    public static var parserOverwrite: Parser?

    override open var parser: Parser {
        return JsonEndpointResolver.parserOverwrite ?? super.parser
    }

    private var entity: DictionaryEntity?

    public func key(for action: String) -> String? {
        return parser.asString(parser.asDictionary(parser.asDictionary(entity?.data)?["keys"])?[action])
    }

    override public init() {
        super.init()

        if let destinations = JsonLoader.load(bundles: Bundle.particles, fileName: "credentials.json") as? [String: Any] {
            entity = DictionaryEntity()
            entity?.parse(dictionary: destinations)
        }
    }
}
