//
//  FieldSliderIntInputPresenter.swift
//  FieldPresenterLib
//
//  Created by Qiang Huang on 10/21/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import UIKit

@objc open class FieldSliderFloatInputPresenter: FieldSliderInputPresenter {
    private var float: Float? {
        get { return field?.float }
        set { field?.float = newValue }
    }

    override open func update() {
        super.update()
        if let min = field?.fieldInput?.min, let max = field?.fieldInput?.max {
            slider?.minimumValue = Float(min - 1) // Add an "Any"
            slider?.maximumValue = Float(max)
            if let float = field?.float {
                slider?.value = float
            } else {
                slider?.value = Float(min - 1)
            }
        }
    }

    override open func slide(commit: Bool) {
        if commit {
            if let min = field?.fieldInput?.min, let value = slider?.value {
                if value >= min {
                    float = value
                } else {
                    float = nil
                }
            }
        }
    }
}
