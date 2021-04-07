//
//  LikedTableViewListPresenter.swift
//  PresenterLib
//
//  Created by Qiang Huang on 11/9/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import ParticlesKit
import RoutingKit
import Utilities

open class LikedTableViewListPresenter: TableViewListPresenter {
    @IBInspectable public var likePath: String?
    @IBInspectable public var dislikePath: String?

    @IBOutlet open var likedManager: LikedObjectsProtocol?

    #if _iOS
        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            if let entity = interactor?.list?[indexPath.row], let key = entity.key, let actions = swipeActions(key: key) {
                let swipeConfig = UISwipeActionsConfiguration(actions: actions)
                return swipeConfig
            }
            return nil
        }

        open func swipeActions(key: String?) -> [UIContextualAction]? {
            if let key = key {
                let like = likeAction(key: key)
                let dislike = dislikeAction(key: key)

                return [dislike, like]
            }
            return nil
        }

        open func likeAction(key: String) -> UIContextualAction {
            let likeAction = UIContextualAction(style: .normal, title: "Like") { [weak self] _, _, completionHandler in
                if let path = self?.likePath {
                    Router.shared?.navigate(to: RoutingRequest(path: path, params: ["key": key]), animated: false, completion: { _, _ in
                        completionHandler(true)
                    })
                } else {
                    completionHandler(true)
                }
//            self?.likedManager?.toggleLike(key: key)
            }
            let liked = likedManager?.liked(key: key) ?? false
            likeAction.image = UIImage.named(liked ? "action_liked" : "action_like", bundles: Bundle.particles)
            return likeAction
        }

        open func dislikeAction(key: String) -> UIContextualAction {
            let dislikeAction = UIContextualAction(style: .normal, title: "Dislike") { [weak self] _, _, completionHandler in
                if let path = self?.dislikePath {
                    Router.shared?.navigate(to: RoutingRequest(path: path, params: ["key": key]), animated: false, completion: { _, _ in
                        completionHandler(true)
                    })
                } else {
                    completionHandler(true)
                }
//            self?.likedManager?.toggleDislike(key: key)
            }
            let disliked = likedManager?.disliked(key: key) ?? false
            dislikeAction.title = disliked ? "It's\nOK" : "Not\nInterested"
//        dislikeAction.image = UIImage.named((disliked ? "action_disliked" : "action_dislike"), bundles: Bundle.particles)
            dislikeAction.backgroundColor = UIColor.red
            return dislikeAction
        }
    #endif
}
