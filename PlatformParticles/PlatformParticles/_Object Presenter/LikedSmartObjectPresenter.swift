//
//  LikedSmartObjectPresenter.swift
//  PresenterLib
//
//  Created by Qiang Huang on 11/6/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import ParticlesKit
import RoutingKit
import UIToolkits

@objc open class LikedSmartObjectPresenter: SmartObjectPresenter {
    @IBInspectable public var likePath: String?
    @IBInspectable public var dislikePath: String?

    @IBOutlet public var likeButton: ButtonProtocol? {
        didSet {
            if likeButton !== oldValue {
                oldValue?.removeTarget()
                likeButton?.addTarget(self, action: #selector(like(_:)))
            }
        }
    }

    @IBOutlet public var dislikeButton: ButtonProtocol? {
        didSet {
            if dislikeButton !== oldValue {
                oldValue?.removeTarget()
                dislikeButton?.addTarget(self, action: #selector(dislike(_:)))
            }
        }
    }

    open var likedManager: LikedObjectsProtocol? {
        didSet {
            changeObservation(from: oldValue, to: likedManager, keyPath: #keyPath(LikedObjectsProtocol.liked)) { [weak self] _, _, _ in
                self?.updateLiked()
            }

            changeObservation(from: oldValue, to: likedManager, keyPath: #keyPath(LikedObjectsProtocol.disliked)) { [weak self] _, _, _ in
                self?.updateDisliked()
            }
        }
    }

    override open func update(layout: Bool) {
        super.update(layout: layout)

        updateLiked()
        updateDisliked()
    }

    open func updateLiked() {
        if let likeButton = likeButton, let key = model?.key {
            if let liked = likedManager?.liked(key: key) {
                let image = UIImage.named(liked ? "action_liked" : "action_like", bundles: Bundle.particles)
                (likeButton as? UIButton)?.setImage(image, for: .normal)
                (likeButton as? UIButton)?.isHidden = false
            } else {
                (likeButton as? UIButton)?.setImage(nil, for: .normal)
                (likeButton as? UIButton)?.isHidden = true
            }
        }
    }

    open func updateDisliked() {
        if let dislikeButton = dislikeButton, let key = model?.key {
            if let disliked = likedManager?.disliked(key: key) {
                let image = UIImage.named(disliked ? "action_disliked" : "action_dislike", bundles: Bundle.particles)
                (dislikeButton as? UIButton)?.setImage(image, for: .normal)
                (dislikeButton as? UIButton)?.isHidden = false
            } else {
                (dislikeButton as? UIButton)?.setImage(nil, for: .normal)
                (dislikeButton as? UIButton)?.isHidden = true
            }
        }
    }

    @IBAction @objc func like(_ sender: Any?) {
        if let key = model?.key as? String, let path = likePath {
            Router.shared?.navigate(to: RoutingRequest(path: path, params: ["key": key]), animated: false, completion: nil)
//            likedManager?.toggleLike(key: key)
        }
    }

    @IBAction @objc func dislike(_ sender: Any?) {
        if let key = model?.key as? String, let path = dislikePath {
            Router.shared?.navigate(to: RoutingRequest(path: path, params: ["key": key]), animated: false, completion: nil)
//            likedManager?.toggleDislike(key: key)
        }
    }
}
