//
//  LikedKeysInteractor.swift
//  InteractorLib
//
//  Created by Qiang Huang on 10/23/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import ParticlesKit

@objc open class LikedKeysInteractor: LocalEntityCacheInteractor, LikedObjectsProtocol {
    private let likedTag = "liked"
    private let dislikedTag = "unliked"

    public var liked: [String]? {
        get { return (entity as? DictionaryEntity)?.force.json?[likedTag] as? [String] }
        set {
            willChangeValue(forKey: #keyPath(liked))
            (entity as? DictionaryEntity)?.force.data?[likedTag] = newValue
            didChangeValue(forKey: #keyPath(liked))
        }
    }

    public var disliked: [String]? {
        get { return (entity as? DictionaryEntity)?.force.json?[dislikedTag] as? [String] }
        set {
            willChangeValue(forKey: #keyPath(disliked))
            (entity as? DictionaryEntity)?.force.data?[dislikedTag] = newValue
            didChangeValue(forKey: #keyPath(disliked))
        }
    }

    open override func createLoader() -> LoaderProtocol? {
        if let path = path {
            return LoaderProvider.shared?.localAsyncLoader(path: path, cache: self)
        }
        return nil
    }

    open override func entityObject() -> ModelObjectProtocol {
        let entity = DictionaryEntity().force
        entity.json?[likedTag] = [String]()
        entity.json?[dislikedTag] = [String]()
        return entity
    }

    public func addLike(key: String?) {
        removeDislike(key: key)
        if let key = key, let liked = liked {
            if liked.firstIndex(of: key) == nil {
                var modified = liked
                modified.append(key)
                self.liked = modified
            }
        }
    }

    public func removeLike(key: String?) {
        if let key = key, let liked = liked {
            if let index = liked.firstIndex(of: key) {
                var modified = liked
                modified.remove(at: index)
                self.liked = modified
            }
        }
    }

    public func toggleLike(key: String?) {
        if let key = key, let liked = liked {
            var modified = liked
            if let index = liked.firstIndex(of: key) {
                modified.remove(at: index)
            } else {
                removeDislike(key: key)
                modified.append(key)
            }
            self.liked = modified
        }
    }

    public func liked(key: String?) -> Bool {
        if let key = key, let liked = liked {
            return liked.firstIndex(of: key) != nil
        }
        return false
    }

    public func addDislike(key: String?) {
        removeLike(key: key)
        if let key = key, let disliked = disliked {
            if disliked.firstIndex(of: key) == nil {
                var modified = disliked
                modified.append(key)
                self.disliked = modified
            }
        }
    }

    public func removeDislike(key: String?) {
        if let key = key, let disliked = disliked {
            if let index = disliked.firstIndex(of: key) {
                var modified = disliked
                modified.remove(at: index)
                self.disliked = modified
            }
        }
    }

    public func toggleDislike(key: String?) {
        if let key = key, let disliked = disliked {
            var modified = disliked
            if let index = disliked.firstIndex(of: key) {
                modified.remove(at: index)
            } else {
                removeLike(key: key)
                modified.append(key)
            }
            self.disliked = modified
        }
    }

    public func disliked(key: String?) -> Bool {
        if let key = key, let disliked = disliked {
            return disliked.firstIndex(of: key) != nil
        }
        return false
    }
}
