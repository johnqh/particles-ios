//
//  LikedObjectsProtocol.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 12/19/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import Foundation

@objc public protocol LikedObjectsProtocol: NSObjectProtocol {
    @objc var liked: [String]? { get set }
    @objc var disliked: [String]? { get set }

    func addLike(key: String?)
    func removeLike(key: String?)
    func toggleLike(key: String?)
    func liked(key: String?) -> Bool
    func addDislike(key: String?)
    func removeDislike(key: String?)
    func toggleDislike(key: String?)
    func disliked(key: String?) -> Bool
}
