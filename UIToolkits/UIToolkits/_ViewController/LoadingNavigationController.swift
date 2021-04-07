//
//  LoadingNavigationController.swift
//  UIToolkits
//
//  Created by Qiang Huang on 11/20/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import KVOController
import UIKit
import Utilities

open class LoadingNavigationController: UXNavigationController, LoadingIndicatorProtocol {
    public var status: LoadingStatusProtocol? {
        didSet {
            changeObservation(from: oldValue, to: status, keyPath: #keyPath(LoadingStatusProtocol.running)) { [weak self] _, _, _ in
                self?.update()
            }
        }
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        status = LoadingStatus.shared
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    open func update() {
    }
}
