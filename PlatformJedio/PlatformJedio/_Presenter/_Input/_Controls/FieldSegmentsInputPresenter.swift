//
//  FieldSegmentsInputPresenter.swift
//  FieldPresenterLib
//
//  Created by Qiang Huang on 10/21/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import UIKit
import Utilities

@objc open class FieldSegmentsInputPresenter: FieldInputPresenter {
    @IBOutlet open var segments: UISegmentedControl? {
        didSet {
            oldValue?.removeTarget(self, action: #selector(select(_:)), for: .valueChanged)
            segments?.addTarget(self, action: #selector(select(_:)), for: .valueChanged)
        }
    }

    override open func update() {
        super.update()

        if let segments = segments {
            segments.removeAllSegments()
            if let options = field?.fieldInput?.options {
                var selected: Int?
                if field?.fieldInput?.optional ?? false {
                    insertSegment(title: "Any", value: nil, index: 0)
                    selected = 0
                }

                for option in options {
                    if let text = parser.asString(option["text"]) {
                        let value = parser.asString(option["value"])
                        let index = segments.numberOfSegments
                        insertSegment(title: text, value: option["value"], index: index)
                        if let value = value {
                            if field?.strings?.contains(value) ?? false {
                                selected = index
                            }
                        } else {
                            if field?.string == nil {
                                selected = index
                            }
                        }
                    }
                }
                if let selected = selected {
                    segments.selectedSegmentIndex = selected
                }
            }
        }
    }

    @IBAction open func select(_ sender: Any?) {
        if let segments = segments {
            if segments.selectedSegmentIndex == 0 && field?.fieldInput?.optional ?? false {
                field?.value = nil
            } else {
                if let text = segments.titleForSegment(at: segments.selectedSegmentIndex), let option = field?.fieldInput?.option(labeled: text) {
                    field?.value = option["value"]
                }
            }
        }
    }

    open func insertSegment(title: String, value: Any?, index: Int) {
        segments?.insertSegment(withTitle: title, at: index, animated: false)
    }
}
