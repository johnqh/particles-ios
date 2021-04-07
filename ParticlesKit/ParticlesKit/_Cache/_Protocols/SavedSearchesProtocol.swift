//
//  SavedSearchesProtocol.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 12/19/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import Foundation

@objc public protocol SavedSearchesProtocol: NSObjectProtocol {
    @objc var savedSearches: [SavedSearchEntity]? { get set }
    func add(name: String, search: String?, filters: [String: Any]?)
    func remove(savedSearch: SavedSearchEntity)
}
