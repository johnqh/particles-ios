//
//  FieldSliderIntInputPresenter.swift
//  FieldPresenterLib
//
//  Created by Qiang Huang on 10/21/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import UIKit

@objc open class FieldSliderIntInputPresenter: FieldSliderInputPresenter {
    private var int: Int? {
        get { return field?.int }
        set { field?.int = newValue }
    }

    override open func update() {
        super.update()
        if let min = field?.fieldInput?.min, let max = field?.fieldInput?.max {
            let minInt = Int(min)
            let maxInt = Int(max)
            slider?.minimumValue = Float(minInt - 1) // Add an "Any"
            slider?.maximumValue = Float(maxInt)
            if let int = field?.int {
                slider?.value = Float(int)
            } else {
                slider?.value = Float(minInt - 1)
            }
        }
    }

    override open func slide(commit: Bool) {
        if commit {
            if let min = field?.fieldInput?.min, let value = slider?.value {
                let minInt = Int(min)
                let intValue = Int(value + 0.5)
                if intValue >= minInt {
                    int = intValue
                } else {
                    int = nil
                }
            }
        }
    }
}
