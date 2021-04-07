//
//  WebApi.swift
//  WebApiLib
//
//  Created by John Huang on 10/11/18.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import RoutingKit
import Utilities

open class WebApi: HttpApi, ApiProtocol {
    public var priority: Int = 10

    #if _iOS || _tvOS
        private var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid
    #endif
    private var dataTask: URLSessionDataTask?

    private var running = false {
        didSet {
            if running != oldValue {
                if running {
                    LoadingStatus.shared.plus()
                } else {
                    LoadingStatus.shared.minus()
                }
            }
        }
    }

    public required init(priority: Int = 10) {
        super.init()
        self.priority = priority
    }

    public required init(server: String? = nil, priority: Int = 10) {
        super.init(server: server)
        self.priority = priority
    }

    public required init(endpointResolver: EndpointResolverProtocol?, priority: Int = 100) {
        super.init(endpointResolver: endpointResolver)
        self.priority = priority
    }

    deinit {
        endBackgroundTask()
        status = nil
        running = false
    }

    public func load(path: String, params: [String: Any]?, completion: @escaping IOReadCompletionHandler) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.get(path: path, params: params) { [weak self] data, error in
                if let self = self {
                    completion(self.result(data: data), self.meta(data: data), self.priority, error)
                }
            }
        }
    }

    open func get(path: String, params: [String: Any]?, completion: @escaping ApiCompletionHandler) {
        run(verb: .get, path: path, params: params, body: nil, completion: completion)
    }

    open func post(path: String, params: [String: Any]?, data: Any?, completion: @escaping ApiCompletionHandler) {
        run(verb: .post, path: path, params: params, body: data, completion: completion)
    }

    open func put(path: String, params: [String: Any]?, data: Any?, completion: @escaping ApiCompletionHandler) {
        run(verb: .put, path: path, params: params, body: data, completion: completion)
    }

    open func delete(path: String, params: [String: Any]?, completion: @escaping ApiCompletionHandler) {
        run(verb: .delete, path: path, params: params, body: nil, completion: completion)
    }

    open func run(verb: HttpVerb, path: String, params: [String: Any]?, body: Any?, completion: @escaping ApiCompletionHandler) {
        if let server = server {
            dataTask?.cancel()

            let pathAndParams = url(server: server, path: path, params: params)
            if pathAndParams.urlPath.contains("{") {
                // unresolved params
                completion(nil, nil)
            } else {
                run(verb: verb, urlPath: pathAndParams.urlPath, paramStrings: pathAndParams.paramStrings, body: body, completion: completion)
            }
        } else {
            completion(nil, nil)
        }
    }

    open func run(verb: HttpVerb, urlPath: String, paramStrings: [String]?, body: Any?, completion: @escaping ApiCompletionHandler) {
        if let data = ApiReplayer.shared?.replay(urlPath: urlPath, params: paramStrings) {
            completion(data, nil)
        } else {
            if let url = url(path: urlPath, params: paramStrings) {
                request(verb: verb, url: url, body: body) { [weak self] request in
                    self?.run(request: request, urlPath: urlPath, paramStrings: paramStrings, completion: completion)
                }
            }
        }
    }

    open func run(request: URLRequest, urlPath: String, paramStrings: [String]?, completion: @escaping ApiCompletionHandler) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 300
        let session = URLSession(configuration: config, delegate: nil, delegateQueue: nil)

        Console.shared.log("API:\(urlPath)\n")
        status = LoadingStatus.shared
        beginBackgroundTask()
        dataTask = session.dataTask(with: request) { [weak self] (raw: Data?, response: URLResponse?, error: Error?) in
            ErrorLogging.shared?.log(error)
            if let self = self {
                DispatchQueue.main.async { [weak self] in
                    self?.status = nil
                }
                self.endBackgroundTask()
                DispatchQueue.main.async {
                    let data = (raw != nil) ? try? JSONSerialization.jsonObject(with: raw!, options: []) : nil

                    if let responseInjections = self.responseInjections {
                        for responseInjection in responseInjections {
                            responseInjection.inject(response: response, data: data, verb: HttpVerb(rawValue: request.httpMethod ?? "GET"))
                        }
                    }
                    if let data = data {
                        #if DEBUG
                            //                            print("Payload:\(data)\n")
                        #endif
                        ApiReplayer.shared?.record(urlPath: urlPath, params: paramStrings, data: data)
                        if let code = (response as? HTTPURLResponse)?.statusCode, code == 204 || !(200 ... 299).contains(code) {
                            let className = String(describing: type(of: self))
                            let error = NSError(domain: "\(className).response.fail", code: code, userInfo: data as? [String: Any])
                            ErrorLogging.shared?.log(error)
                            if code == 401 {
                                Router.shared?.navigate(to: RoutingRequest(path: "/action/logout", params: ["notify": true]), animated: true, completion: nil)
                            }
                            completion(data, error)
                        } else {
                            completion(data, error)
                        }
                    } else {
                        if error != nil {
                            completion(nil, error)
                        } else {
                            let className = String(describing: type(of: self))
                            let error = NSError(domain: "\(className).response.fail", code: (response as? HTTPURLResponse)?.statusCode ?? 0, userInfo: ["description": (response as? HTTPURLResponse)?.description ?? "none"])
                            completion(nil, error)
                        }
                    }
                }
            }
        }
        dataTask?.resume()
    }

    private func beginBackgroundTask() {
        #if _iOS || _tvOS
            if backgroundTaskId == .invalid {
                running = true
                backgroundTaskId = UIApplication.shared.beginBackgroundTask { [weak self] in
                    self?.endBackgroundTask()
                }
            }
        #endif
    }

    private func endBackgroundTask() {
        #if _iOS || _tvOS
            if backgroundTaskId != .invalid {
                UIApplication.shared.endBackgroundTask(backgroundTaskId)
                backgroundTaskId = .invalid
                running = false
            }
        #endif
    }
}
