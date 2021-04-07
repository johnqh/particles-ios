//
//  LikedFieldsViewController.swift
//  FieldPresenterLib
//
//  Created by Qiang Huang on 11/9/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import ParticlesKit
import PlatformParticles

open class LikedFieldsViewController: FieldsViewController {
    open var likedManager: LikedObjectsProtocol? {
        didSet {
            likePresenter?.likedManager = likedManager
        }
    }

    @IBOutlet var likePresenter: ObjectLikeBarItemPresenter? {
        didSet {
            likePresenter?.model = entity
            likePresenter?.likedManager = likedManager
        }
    }

    open override var entity: ModelObjectProtocol? {
        didSet {
            likePresenter?.model = entity
            title = entity?.displayTitle ?? nil
        }
    }
}
