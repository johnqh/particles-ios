//
//  ShareAction.swift
//  PlatformRouting
//
//  Created by Qiang Huang on 11/2/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import RoutingKit
import UIToolkits

open class ShareAction: NSObject, NavigableProtocol {
    private var completion: RoutingCompletionBlock?
    open func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        switch request?.path {
        case "/action/share":
            if let text = parser.asString(request?.params?["text"])?.decodeUrl(), let link = parser.asString(request?.params?["link"]), let linkUrl = NSURL(string: link) {
                let toShare: [Any] = [text, linkUrl]
                let activityVC = UIActivityViewController(activityItems: toShare, applicationActivities: nil)
                activityVC.excludedActivityTypes = [
                    UIActivity.ActivityType.airDrop,
                    UIActivity.ActivityType.addToReadingList,
                ]

                activityVC.popoverPresentationController?.sourceView = UserInteraction.shared.sender as? UIView
                activityVC.popoverPresentationController?.barButtonItem = UserInteraction.shared.sender as? UIBarButtonItem
                UIViewController.topmost()?.present(activityVC, animated: true, completion: nil)
                completion?(nil, true)
            } else {
                completion?(nil, false)
            }
        default:
            completion?(nil, false)
        }
    }
}
