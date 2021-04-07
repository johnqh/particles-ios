//
//  RoutingRequest.swift
//  RoutingKit
//
//  Created by Qiang Huang on 10/11/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import Foundation

@objc public class RoutingRequest: NSObject {
    public var scheme: String?
    public var host: String?
    public var path: String?
    public var params: [String: Any]?

    public var presentation: RoutingPresentation?

    public var url: URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path ?? "/"
        if let params = params, params.count > 0 {
            urlComponents.queryItems = params.compactMap({ (arg0) -> URLQueryItem? in
                let (key, value) = arg0
                return URLQueryItem(name: key, value: parser.asString(value))
            })
        }
        return urlComponents.url
    }

    public init(scheme: String? = nil, host: String? = nil, path: String, params: [String: Any]? = nil) {
        self.scheme = scheme
        self.host = host
        self.path = path
        self.params = params
        super.init()
    }

    public init(url: String?) {
        if let url = url, let urlComponents = URLComponents(string: url) {
            scheme = urlComponents.scheme
            host = urlComponents.host?.trim()
            path = urlComponents.path.trim()
            params = urlComponents.params
        }
        super.init()
    }
}
