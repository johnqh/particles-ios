//
//  RoutingTabBarController.swift
//  PlatformRouting
//
//  Created by Qiang Huang on 12/1/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import Differ
import ParticlesKit
import RoutingKit
import UIToolkits
import Utilities

open class RoutingTabBarController: UITabBarController, ParsingProtocol {
    @objc public dynamic var badging: UrlBadgingInteractor? {
        didSet {
            changeObservation(from: oldValue, to: badging, keyPath: #keyPath(UrlBadgingInteractor.dictionary)) { [weak self] _, _, _ in
                if let self = self {
                    self.updateBadging()
                }
            }
        }
    }

    public static var parserOverwrite: Parser?

    override open var parser: Parser {
        return RoutingTabBarController.parserOverwrite ?? super.parser
    }

    public var maps: [TabbarItemInfo]? {
        didSet {
            if maps != oldValue {
                let current = maps ?? [TabbarItemInfo]()
                let old = oldValue ?? [TabbarItemInfo]()
                let diff: Diff = self.diff(current: current, old: old)
                let patches = self.patches(diff: diff, current: current, old: old)
                update(diff: diff, patches: patches)
                updateBadging()
            }
        }
    }

    @IBInspectable var path: String?

    @IBInspectable open var routingMap: String? {
        didSet {
            if routingMap != oldValue {
                if let destinations = parser.asArray(JsonLoader.load(bundles: Bundle.particles, fileName: routingMap)) {
                    parse(array: destinations)
                }
            }
        }
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        RoutingHistory.shared.record(destination: self)
    }

    public func parse(array: [Any]) {
        if let data = array as? [[String: Any]] {
            var maps = [TabbarItemInfo]()
            for dictionary in data {
                let routing = TabbarItemInfo()
                routing.parse(dictionary: dictionary)
                maps.append(routing)
            }
            self.maps = maps
        }
    }

    open func diff(current: [TabbarItemInfo], old: [TabbarItemInfo]) -> Diff {
        return old.diff(current) { (object1, object2) -> Bool in
            object1.path == object2.path
        }
    }

    open func patches(diff: Diff, current: [TabbarItemInfo], old: [TabbarItemInfo]) -> [Patch<TabbarItemInfo>] {
        return diff.patch(from: old, to: current) { (element1, element2) -> Bool in
            switch (element1, element2) {
            case let (.insert(at1), .insert(at2)):
                return at1 < at2
            case (.insert, .delete):
                return false
            case (.delete, .insert):
                return true
            case let (.delete(at1), .delete(at2)):
                return at1 > at2
            }
        }
    }

    open func update(diff: Diff, patches: [Patch<TabbarItemInfo>]) {
        var viewControllers = self.viewControllers ?? [UIViewController]()
        for change in patches {
            switch change {
            case let .deletion(index):
                viewControllers.remove(at: index)

            case let .insertion(index: index, element: item):
                if let viewController = installViewController(for: item) {
                    if index >= viewControllers.count {
                        viewControllers.append(viewController)
                    } else {
                        viewControllers.insert(viewController, at: index)
                    }
                }
            }
        }
        self.viewControllers = viewControllers
    }

    open func installViewController(for info: TabbarItemInfo) -> UIViewController? {
        if let path = info.path {
            if let viewController = (Router.shared as? MappedUIKitRouter)?.viewController(for: path) {
                if let path = info.path, let nav = viewController as? NavigableProtocol {
                    let request = RoutingRequest(path: path)
                    nav.navigate(to: request, animated: false, completion: nil)
                }
                if UIDevice.current.canSplit && (info.split ?? false) {
                    let splitter = UISplitViewController()
                    splitter.preferredDisplayMode = .allVisible
                    if let nav = UINavigationController.load(storyboard: "Nav", with: viewController), let rightNav = UINavigationController.loadNavigator(storyboard: "Nav") {
                        splitter.viewControllers = [nav, rightNav]

                        let tabbarItem = UITabBarItem()
                        tabbarItem.title = info.title
                        if let image = info.image {
                            tabbarItem.image = UIImage.named(image, bundles: Bundle.particles)
                        }
                        if let selected = info.selected {
                            tabbarItem.selectedImage = UIImage.named(selected, bundles: Bundle.particles)
                        }
                        splitter.tabBarItem = tabbarItem

                        return splitter
                    } else {
                        return nil
                    }
                } else {
                    var tabViewController: UIViewController = viewController
                    if !(viewController is UIViewControllerEmbeddingProtocol) {
                        if let nav = UINavigationController.load(storyboard: "Nav", with: viewController) {
                            tabViewController = nav
                        }
                    }
                    let tabbarItem = UITabBarItem()
                    tabbarItem.title = info.title?.localized
                    if let image = info.image {
                        tabbarItem.image = UIImage.named(image, bundles: Bundle.particles)
                    }
                    if let selected = info.selected {
                        tabbarItem.selectedImage = UIImage.named(selected, bundles: Bundle.particles)
                    }
                    tabViewController.tabBarItem = tabbarItem
                    return tabViewController
                }
            }
        }
        return nil
    }

    open func updateBadging() {
        if let viewControllers = viewControllers, let maps = maps, viewControllers.count == maps.count {
            for i in 0 ..< maps.count {
                let viewController = viewControllers[i]
                if let tabbarItem = viewController.tabBarItem {
                    let map = maps[i]
                    if let path = map.path {
                        tabbarItem.badgeValue = badging?.badge(for: path)
                    } else {
                        tabbarItem.badgeValue = nil
                    }
                }
            }
        }
    }
}

public class TabbarItemInfo: NSObject, ParsingProtocol {
    override open var parser: Parser {
        return RoutingTabBarController.parserOverwrite ?? super.parser
    }

    public var path: String?
    public var title: String?
    public var image: String?
    public var selected: String?
    public var split: Bool?

    public func parse(dictionary: [String: Any]) {
        path = parser.asString(dictionary["path"])
        title = parser.asString(dictionary["title"])
        image = parser.asString(dictionary["image"])
        selected = parser.asString(dictionary["selected"])
        split = parser.asBoolean(dictionary["split"])?.boolValue
    }
}
