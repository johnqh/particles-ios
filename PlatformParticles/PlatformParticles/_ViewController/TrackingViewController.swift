//
//  TrackingViewController.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 12/20/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import ParticlesKit
import PlatformRouting
import Utilities

open class TrackingViewController: NavigableViewController {
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.setNeedsLayout()
        }
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Tracking.shared?.path(history?.path, data: history?.params)
    }
}
