//
//  SettingsViewController.swift
//  PlatformJedio
//
//  Created by Qiang Huang on 4/27/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import RoutingKit
import UIKit
import Utilities

open class SettingsViewController: DataInputViewController {
    @IBOutlet var debugButton: UIBarButtonItem? {
        didSet {
            if debugButton !== oldValue {
                oldValue?.removeTarget()
                debugButton?.addTarget(self, action: #selector(debug(_:)))
            }
        }
    }

    @IBOutlet var featuresButton: UIBarButtonItem? {
        didSet {
            if featuresButton !== oldValue {
                oldValue?.removeTarget()
                featuresButton?.addTarget(self, action: #selector(features(_:)))
            }
        }
    }

    @IBOutlet var crashButton: UIBarButtonItem? {
        didSet {
            if crashButton !== oldValue {
                oldValue?.removeTarget()
                crashButton?.addTarget(self, action: #selector(crash(_:)))
            }
        }
    }

    private var shown: Bool = false

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !shown {
            if presenting() {
                navigationItem.leftBarButtonItem = cancelButton as? UIBarButtonItem
            } else {
                navigationItem.leftBarButtonItem = nil
            }
            shown = true
        }
    }

    override open func setupButtons() {
        var buttons = [UIBarButtonItem]()
        if !Installation.appStore {
            if UserDefaults.standard.bool(forKey: "debug.enabled") {
                if let featuresButton = featuresButton {
                    buttons.append(featuresButton)
                }
                if let debugButton = debugButton {
                    buttons.append(debugButton)
                }
            }
        }
        if navigationController?.presentingViewController != nil || presenting() {
            if let doneButton = doneButton as? UIBarButtonItem {
                buttons.append(doneButton)
            }
        }
        navigationItem.rightBarButtonItems = (buttons.count > 0) ? buttons : nil
    }

    @IBAction func debug(_ sender: Any?) {
        Router.shared?.navigate(to: RoutingRequest(path: "/debug"), animated: true, completion: nil)
    }

    @IBAction func features(_ sender: Any?) {
        Router.shared?.navigate(to: RoutingRequest(path: "/features"), animated: true, completion: nil)
    }

    @IBAction func crash(_ sender: Any?) {
    }
}
