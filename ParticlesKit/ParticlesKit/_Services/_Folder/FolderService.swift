//
//  FolderService.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 12/25/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import Utilities

public protocol FolderProviderProtocol {
    func documents() -> String?
    func temp() -> String?
}

public class FolderService {
    public static var shared: FolderProviderProtocol?
}

public class RealFolderProvider: FolderProviderProtocol {
    public var documentFolder: String? {
        didSet {
            _ = Directory.ensure(documentFolder)
        }
    }

    public var tempFolder: String? {
        didSet {
            _ = Directory.ensure(tempFolder)
        }
    }

    public static func mock() -> RealFolderProvider {
        let provider = RealFolderProvider()
        provider.documentFolder = ProcessInfo.processInfo.environment["TEST_DOCUMENTS_DIR"]
        provider.tempFolder = ProcessInfo.processInfo.environment["TEST_TEMP_DIR"]
        return provider
    }

    public init() {
    }

    public func documents() -> String? {
        return documentFolder ?? Directory.document
    }

    public func temp() -> String? {
        return tempFolder ?? Directory.cache
    }
}
