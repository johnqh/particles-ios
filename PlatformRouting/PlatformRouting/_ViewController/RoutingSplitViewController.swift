//
//  RoutingSplitViewController.swift
//  PlatformRouting
//
//  Created by Qiang Huang on 1/20/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import RoutingKit
import UIToolkits
import Utilities

open class RoutingSplitViewController: UISplitViewController, ParsingProtocol {
    override open var parser: Parser {
        return RoutingTabBarController.parserOverwrite ?? super.parser
    }

    public var show: String?
    public var detail: String?

    @IBInspectable var path: String?

    @IBInspectable open var routingMap: String? {
        didSet {
            if routingMap != oldValue {
                if let destinations = parser.asDictionary(JsonLoader.load(bundles: Bundle.particles, fileName: routingMap)) {
                    show = parser.asString(destinations["show"])
                    detail = parser.asString(destinations["detail"])
                }
            }
        }
    }

    public var left: UIViewController? {
        didSet {
            if left !== oldValue {
                installLeft()
            }
        }
    }

    public var center: UIViewController? {
        didSet {
            if center !== oldValue {
                installCenter()
            }
        }
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        preferredDisplayMode = .allVisible

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.installViewControllers()
        }
    }

    open func installViewController(path: String?, nav: Bool) -> UIViewController? {
        if let path = path, let viewController = (Router.shared as? MappedUIKitRouter)?.viewController(for: path) {
            if nav {
                if let nav = UINavigationController.loadNavigator(storyboard: "Nav") {
                    nav.viewControllers = [viewController]
                    return nav
                }
            } else {
                return viewController
            }
        }
        return nil
    }

    open func installViewControllers() {
        if let left = installViewController(path: show, nav: true) {
            self.left = left
            if let center = installViewController(path: detail, nav: true) {
                self.center = center
            }
        }
    }

    open func installLeft() {
        if let left = left {
            viewControllers = [left]
            if let show = show {
                DispatchQueue.main.async { [weak self] in
                    if let self = self {
                        (self.left as? NavigableProtocol)?.navigate(to: RoutingRequest(path: show), animated: true, completion: nil)
                    }
                }
            }
        }
    }

    open func installCenter() {
        if let center = center, let left = left {
            viewControllers = [left, center]
            if let detail = detail {
                DispatchQueue.main.async { [weak self] in
                    if let self = self {
                        (self.center as? NavigableProtocol)?.navigate(to: RoutingRequest(path: detail), animated: true, completion: nil)
                    }
                }
            }
        }
    }

    public var history: RoutingRequest? {
        return RoutingRequest(path: path ?? "/")
    }

    override public func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        if request?.path == (path ?? "/") {
            completion?(self, true)
        } else {
            super.navigate(to: request, animated: animated, completion: completion)
        }
    }
}
