//
//  FieldSliderInputPresenter.swift
//  FieldPresenterLib
//
//  Created by Qiang Huang on 10/21/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import UIKit

@objc open class FieldSliderInputPresenter: FieldInputPresenter {
    @IBOutlet var slider: UISlider? {
        didSet {
            slider?.isContinuous = false
            oldValue?.removeTarget(self, action: #selector(slide(_:)), for: .valueChanged)
            slider?.addTarget(self, action: #selector(slide(_:)), for: .valueChanged)
            oldValue?.removeTarget(self, action: #selector(slideDone(_:)), for: .touchUpInside)
            slider?.addTarget(self, action: #selector(slideDone(_:)), for: .touchUpInside)
            oldValue?.removeTarget(self, action: #selector(slideCancel(_:)), for: .touchUpOutside)
            slider?.addTarget(self, action: #selector(slideCancel(_:)), for: .touchUpOutside)
        }
    }

    @IBAction open func slide(_ sender: Any?) {
        slide(commit: false)
    }

    @IBAction open func slideDone(_ sender: Any?) {
        slide(commit: true)
    }

    @IBAction open func slideCancel(_ sender: Any?) {
        update()
    }

    open func slide(commit: Bool) {
    }
}
