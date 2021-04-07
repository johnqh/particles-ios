//
//  RoutingDrawerController.swift
//  PlatformRouting
//
//  Created by Qiang Huang on 7/12/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import DrawerMenu
import RoutingKit
import UIToolkits
import Utilities

open class RoutingDrawerController: UIViewController, UIViewControllerDrawerProtocol, ParsingProtocol {
    override open var parser: Parser {
        return RoutingTabBarController.parserOverwrite ?? super.parser
    }

    public var drawer: String?
    public var root: String?

    @IBInspectable var path: String?

    @IBInspectable open var routingMap: String? {
        didSet {
            if routingMap != oldValue {
                if let destinations = parser.asDictionary(JsonLoader.load(bundles: Bundle.particles, fileName: routingMap)) {
                    drawer = parser.asString(destinations["drawer"])
                    root = parser.asString(destinations["root"])
                }
            }
        }
    }

    public var drawerMenu: DrawerMenu?
    public var center: UIViewController?
    public var left: UIViewController?

    public var isOpen: Bool {
        return drawerMenu?.isOpenLeft ?? false
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        if let center = installViewController(path: root, nav: false), let left = installViewController(path: drawer, nav: true) {
            let drawer = DrawerMenu(center: center, left: left)
            drawer.panGestureType = .none
            if UIDevice.current.userInterfaceIdiom == .pad {
                drawer.leftMenuWidth = 320.0
            }
            addChild(drawer)
            view.addSubview(drawer.view)
            drawer.didMove(toParent: self)

            self.center = center
            self.left = left
            drawerMenu = drawer
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

    override public func topmost() -> UIViewController? {
        if isOpen {
            return left?.topmost() ?? super.topmost()
        } else {
            return center?.topmost() ?? super.topmost()
        }
    }
}

extension RoutingDrawerController: NavigableProtocol {
    public var history: RoutingRequest? {
        return RoutingRequest(path: path ?? "/")
    }

    public func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        if request?.path == (path ?? "/") {
            completion?(self, true)
        } else {
            navigate(to: request, viewController: center, animated: animated) { [weak self] destination, succeeded in
                if let self = self {
                    if succeeded {
                        completion?(destination, succeeded)
                    } else {
                        self.navigate(to: request, viewController: self.left, animated: animated, completion: { [weak self] destination, completed in
                            if completed {
                                self?.drawerMenu?.open(to: .left)
                            }
                            completion?(destination, completed)
                        })
                    }
                }
            }
        }
    }

    public func navigate(to request: RoutingRequest?, viewController: UIViewController?, animated: Bool, completion: RoutingCompletionBlock?) {
        if let viewController = viewController as? NavigableProtocol {
            viewController.navigate(to: request, animated: animated) { _, completed in
                if completed {
                    completion?(viewController, true)
                } else {
                    completion?(nil, false)
                }
            }
        } else {
            completion?(nil, false)
        }
    }
}
