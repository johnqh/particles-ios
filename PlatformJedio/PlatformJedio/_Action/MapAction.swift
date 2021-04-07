//
//  MapAction.swift
//  PlatformJedio
//
//  Created by Qiang Huang on 8/6/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import JedioKit
import ParticlesKit
import PlatformParticles
import RoutingKit
import UIToolkits
import Utilities

open class MapAction: ConfirmationAction {
    @IBOutlet open var fieldLoader: MapFieldLoader?
    @IBOutlet open var mapCache: LocalEntityCacheInteractor?

    private var inputDefinition: FieldInputDefinition? {
        return fieldLoader?.definitionGroups?.first?.definitions?.first as? FieldInputDefinition
    }

    public var params: [String: Any]?
    private var addressParam: String?
    private var coordinateParam: String?
    private var backUrlParam: String?

    open var mapUrl: String? {
        get {
            return parser.asString((mapCache?.entity as? DictionaryEntity)?.data?["map"])
        }
        set {
            (mapCache?.entity as? DictionaryEntity)?.force.data?["map"] = newValue
            mapCache?.save()
            navigate()
        }
    }

    open override func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        if request?.path == "/action/map" {
            Tracking.shared?.path(request?.path, data: nil)
            let address = parser.asString(request?.params?["address"])
            let lat = parser.asNumber(request?.params?["lat"])
            let lng = parser.asNumber(request?.params?["lng"])
            if address != nil || lat != nil || lng != nil {
                params = request?.params
                loadMapUrl(completion: completion)
            } else {
                completion?(nil, false)
            }
        } else {
            completion?(nil, false)
        }
    }

    private func loadMapUrl(completion: RoutingCompletionBlock?) {
        prompt(mapUrl: mapUrl, completion: completion)
    }

    private func prompt(mapUrl: String?, completion: RoutingCompletionBlock?) {
        if let definition = inputDefinition, let key = definition.field?["field"] as? String, let options = definition.options {
            if options.count == 1, let option = options.first, let value = option["value"] as? String {
                set(mapUrl: value)
            } else if options.count > 1 {
                if let prompter = PrompterFactory.shared?.prompter() {
                    prompter.set(title: "Select which routing app you would like to use", message: nil, style: .selection)
                    var promptActions = [PrompterAction]()
                    var found = false
                    for option in options {
                        if let text = option["text"] as? String, let value = option["value"] as? String {
                            if value == mapUrl {
                                found = true
                            } else {
                                let action = PrompterAction(title: text, style: .normal, enabled: true) { [weak self] in
                                    if let self = self {
                                        var data: [String: Any] = self.mapCache?.dictionaryEntity?.data ?? [:]
                                        data[key] = value
                                        self.mapCache?.dictionaryEntity?.data = data
                                        self.set(mapUrl: value)
                                    }
                                }
                                promptActions.append(action)
                            }
                        }
                    }
                    if found {
                        set(mapUrl: mapUrl)
                    } else {
                        confirm(confirmation: prompter, actions: promptActions, completion: completion)
                    }
                }
            }
        }
    }

    open func set(mapUrl: String?) {
        self.mapUrl = mapUrl
    }

    private func option(mapUrl: String?) -> [String: Any]? {
        if let definition = inputDefinition, let options = definition.options, let mapUrl = mapUrl {
            return options.first { (option) -> Bool in
                let value = parser.asString(option["value"])
                return value == mapUrl
            }
        }
        return nil
    }

    open func navigate() {
        reallyNavigate()
    }

    open func reallyNavigate() {
        if let mapUrl = mapUrl, var url = URL(string: mapUrl), var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            let option = self.option(mapUrl: mapUrl)
            if let link = option?["link"] as? String {
                if let linkUrl = URL(string: link), let linkUrlComponents = URLComponents(url: linkUrl, resolvingAgainstBaseURL: false) {
                    url = linkUrl
                    urlComponents = linkUrlComponents
                }
            }
            // "link":"comgooglemapsurl://maps.google.com/maps",
            let addressParam = option?["address"] as? String ?? "address"
            let coordinateParam = option?["coordinate"] as? String ?? "ll"
            let appParam = (option?["app"] as? String)?.replacingOccurrences(of: " ", with: "+")
            let backUrlParam = option?["backUrl"] as? String
            let drivingParam = option?["driving"] as? String

            var params: [String: String] = [:]
            if let address = parser.asString(self.params?["address"]) {
                params[addressParam] = address
            }
            if let lat = parser.asNumber(self.params?["lat"]), let lng = parser.asNumber(self.params?["lng"]) {
                params[coordinateParam] = "\(lat),\(lng)"
            }
            if let driving = parser.asString(self.params?["driving"]), let drivingParam = drivingParam {
                params[driving] = drivingParam
            }
            if let additional = option?["additional"] as? [String: String] {
                for arg0 in additional {
                    let (key, value) = arg0
                    params[key] = value
                }
            }
            if let app = parser.asString(self.params?["app"]), let appParam = appParam {
                params[app] = appParam
            }
            if let backUrl = parser.asString(self.params?["backUrl"]), let backUrlParam = backUrlParam {
                params[backUrl] = backUrlParam
            }

            urlComponents.queryItems = params.map({ (arg0) -> URLQueryItem in
                let (key, value) = arg0
                return URLQueryItem(name: key, value: parser.asString(value))
            })
            if let finalUrl = urlComponents.url {
                URLHandler.shared?.open(finalUrl) { [weak self] _ in
                    self?.complete(successful: true)
                }
            } else {
                complete(successful: false)
            }
        } else {
            complete(successful: false)
        }
    }
}
