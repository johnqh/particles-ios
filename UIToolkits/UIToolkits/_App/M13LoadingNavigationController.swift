//
//  M13LoadingNavigationController.swift
//  UIAppToolkits
//
//  Created by Qiang Huang on 12/30/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import M13ProgressSuite
import UIKit

open class M13LoadingNavigationController: LoadingNavigationController {
    private var running: Bool = false {
        didSet {
            if running != oldValue {
                if running {
                    finishTimer = nil
                    setIndeterminate(true)
                    showProgress()
                } else {
                    finishTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
                        if let self = self {
                            self.finishProgress()
                            self.finishTimer = nil
                        }
                    })
                }
            }
        }
    }

    private var finishTimer: Timer? {
        didSet {
            if finishTimer !== oldValue {
                if let oldValue = oldValue {
                    oldValue.invalidate()
                }
            }
        }
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        setPrimaryColor(UIColor.lightGray)
    }

    open override func update() {
        running = status?.running ?? false
    }
}
