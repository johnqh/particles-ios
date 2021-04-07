//
//  FieldSliderIntInputPresenter.swift
//  FieldPresenterLib
//
//  Created by Qiang Huang on 10/21/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import UIKit

@objc open class FieldSliderPercentInputPresenter: FieldSliderInputPresenter {
    private var percent: Float? {
        get { return field?.percent }
        set { field?.percent = newValue }
    }

    override open func update() {
        super.update()
        slider?.minimumValue = -1 // Add an "Any"
        slider?.maximumValue = 100.0
        if let percent = field?.percent {
            slider?.value = percent * 100.0
        } else {
            slider?.value = -1
        }
    }

    override open func slide(commit: Bool) {
        if commit {
            if let value = slider?.value {
                if value >= 0 {
                    percent = value / 100.0
                } else {
                    percent = nil
                }
            }
        }
    }
}
