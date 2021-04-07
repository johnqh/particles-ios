//
//  MappedRouter.swift
//  RoutingKit
//
//  Created by Qiang Huang on 10/11/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import Foundation
import Utilities

public enum RoutingPresentation: Int {
    case root
    case show
    case detail
    case prompt
    case callout
    case half
    case float
    case embed
    case drawer
}

public class RoutingMap: NSObject, ParsingProtocol {
    public var destination: String
    public var dependencies: [RoutingRequest]?
    public var presentation: RoutingPresentation?

    override open var parser: Parser {
        return MappedRouter.parserOverwrite ?? super.parser
    }

    public init(destination: String) {
        self.destination = destination
        super.init()
    }

    public func parse(dictionary: [String: Any]) {
        dependencies = parseDependencies(dictionary: dictionary)
        switch parser.asString(dictionary["presentation"]) {
        case "root":
            presentation = .root

        case "drawer":
            presentation = .drawer

        case "show":
            presentation = .show

        case "detail":
            presentation = .detail

        case "prompt":
            presentation = .prompt

        case "callout":
            presentation = .callout

        case "half":
            presentation = .half

        case "float":
            presentation = .float

        case "embed":
            presentation = .embed

        default:
            presentation = nil
        }
    }

    public func parseDependencies(dictionary: [String: Any]) -> [RoutingRequest]? {
        if let dependencies = parser.asArray(dictionary["dependencies"]) {
            var requests = [RoutingRequest]()
            for dependency in dependencies {
                if let data = parser.asDictionary(dependency), let path = parser.asString(data["path"]) {
                    let params = parser.asDictionary(data["params"])
                    let request = RoutingRequest(path: path, params: params)
                    requests.append(request)
                } else if let path = parser.asString(dependency) {
                    let request = RoutingRequest(path: path)
                    requests.append(request)
                } else {
                    Console.shared.log("Error: parsing route dependencies")
                }
            }
            return requests
        }
        return nil
    }
}

open class MappedRouter: NSObject, RouterProtocol, ParsingProtocol {
    
    public static var parserOverwrite: Parser?

    override open var parser: Parser {
        return MappedRouter.parserOverwrite ?? super.parser
    }

    public var disabled: Bool = false
    public var defaults: [String: String]?
    public var aliases: [String: String]?
    public var maps: [String: [String: [String: RoutingMap]]]? // ["http":["www.domain.com": ["/": "Home]]]
//    public var shared: [String: RoutingMap]
    public init(file: String) {
        super.init()
        let shared = JsonLoader.load(bundles: Bundle.particles, fileName: "routing_shared.json") as? [String: Any]
        if let destinations = JsonLoader.load(bundles: Bundle.particles, fileName: file) as? [String: Any] {
            parse(dictionary: destinations, shared: shared)
        }
    }

    public func parse(dictionary: [String: Any], shared: [String: Any]?) {
        if let defaultData = dictionary["defaults"] as? [String: String] {
            if defaults == nil {
                defaults = defaultData
            } else {
                defaults = defaults?.merging(defaultData, uniquingKeysWith: { (_, value2) -> String in
                    value2
                })
            }
        }
        if let aliasesData = dictionary["aliases"] as? [String: String] {
            if aliases == nil {
                aliases = aliasesData
            } else {
                aliases = aliases?.merging(aliasesData, uniquingKeysWith: { (_, value2) -> String in
                    value2
                })
            }
        }
        if let schemaMaps = parseMaps(dictionary: dictionary["mapping"] as? [String: Any], shared: shared) {
            if maps == nil {
                maps = schemaMaps
            } else {
                maps = maps?.merging(schemaMaps, uniquingKeysWith: { (_, value2) -> [String: [String: RoutingMap]] in
                    value2
                })
            }
        }
    }

    private func parseMaps(dictionary: [String: Any]?, shared: [String: Any]?) -> [String: [String: [String: RoutingMap]]]? {
        if let dictionary = dictionary {
            var schemeMaps = [String: [String: [String: RoutingMap]]]()
            for (scheme, value) in dictionary {
                if let dictionary = value as? [String: Any] {
                    var hostMaps = [String: [String: RoutingMap]]()
                    for (host, value) in dictionary {
                        if let dictionary = merge(host: host, destination: value as? [String: Any], with: shared) {
                            var maps = [String: RoutingMap]()
                            for (key, value) in dictionary {
                                if let dictionary = parser.asDictionary(value), let destination = parser.asString(dictionary["destination"]) {
                                    let routing = map(destination: destination)
                                    routing.parse(dictionary: dictionary)
                                    maps[key] = routing
                                }
                            }
                            hostMaps[host] = maps
                        }
                    }
                    schemeMaps[scheme] = hostMaps
                }
            }
            return schemeMaps
        }
        return nil
    }

    private func merge(host: String, destination: [String: Any]?, with shared: [String: Any]?) -> [String: Any]? {
        if host == "*" {
            return destination
        } else {
            if let destination = destination {
                if let shared = shared {
                    return destination.merging(shared) { (value1, _) -> Any in
                        value1
                    }
                } else {
                    return destination
                }
            } else {
                return shared
            }
        }
    }

    open func map(destination: String) -> RoutingMap {
        return RoutingMap(destination: destination)
    }

    open func navigate(to request: RoutingRequest, presentation: RoutingPresentation?, animated: Bool, completion: RoutingCompletionBlock?) {
        if disabled {
            completion?(nil, false)
        } else {
            let transformed = transform(request: request)
            if let map = self.map(for: transformed) {
                backtrack(request: transformed, animated: animated) { [weak self] _, completed in
                    if completed {
                        completion?(nil, true)
                    } else {
                        self?.route(dependencies: map, request: transformed, completion: { [weak self] _, successful in
                            if successful {
                                self?.navigate(to: map, request: transformed, presentation: presentation ?? transformed.presentation, animated: animated, completion: completion)
                            } else {
                                completion?(nil, false)
                            }
                        })
                    }
                }
            } else {
                if let url = request.url {
                    URLHandler.shared?.open(url, completionHandler: { successful in
                        completion?(nil, successful)
                    })
                } else {
                    completion?(nil, false)
                }
            }
        }
    }

    open func transform(request: RoutingRequest) -> RoutingRequest {
        if let path = request.path {
            let transformed = RoutingRequest(scheme: transform(request.scheme, default: defaults?["scheme"]), host: transform(request.host, default: defaults?["host"]), path: path.trim() ?? "/", params: request.params)

            transformed.presentation = request.presentation
            return transformed
        }
        return request
    }

    open func transform(_ string: String?, default fallback: String?) -> String? {
        if let string = string {
            return aliases?[string] ?? string
        } else {
            return fallback
        }
    }

    open func map(for request: RoutingRequest) -> RoutingMap? {
        var scheme: String? = request.scheme ?? defaults?["scheme"]
        if let input = scheme, let alias = aliases?[input] {
            scheme = alias
        }
        var host: String? = request.host ?? defaults?["host"]
        if let input = host, let alias = aliases?[input] {
            host = alias
        }
        if let scheme = scheme, let host = host {
            if let path = request.path {
                return maps?[scheme]?[host]?[path] ?? maps?[scheme]?[host]?["*"] ?? maps?[scheme]?["*"]?["*"]
            } else {
                return maps?[scheme]?[host]?["*"] ?? maps?[scheme]?["*"]?["*"]
            }
        }

        return nil
    }

    open func backtrack(request: RoutingRequest, animated: Bool, completion: RoutingCompletionBlock?) {
        completion?(nil, false)
    }

    open func route(dependencies map: RoutingMap, index: Int = 0, request: RoutingRequest, completion: RoutingCompletionBlock?) {
        if index < map.dependencies?.count ?? 0, let dependency = map.dependencies?[index], let path = dependency.path {
            var params = dependency.params ?? [String: Any]()
            if let others = request.params {
                params.merge(others) { (_, value2) -> Any in
                    value2
                }
            }
            let request = RoutingRequest(path: path, params: params)
            navigate(to: request, presentation: nil, animated: false) { [weak self] _, successful in
                if successful {
                    self?.route(dependencies: map, index: index + 1, request: request, completion: completion)
                } else {
                    completion?(nil, false)
                }
            }
        } else {
            completion?(nil, true)
        }
    }

    open func navigate(to map: RoutingMap, request: RoutingRequest, presentation: RoutingPresentation?, animated: Bool, completion: RoutingCompletionBlock?) {
        completion?(nil, false)
    }

    public func navigate(to url: URL?, completion: RoutingCompletionBlock?) {
        // Sample URL app://go.to/path...
        if let path = url?.path {
            navigate(to: RoutingRequest(scheme: url?.scheme, host: url?.host, path: path, params: url?.params), presentation: nil, animated: true, completion: completion)
        }
    }
}
