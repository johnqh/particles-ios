//
//  HMSegmentedControl+SegmentedProtocol.swift
//  UIToolkits
//
//  Created by Qiang Huang on 12/26/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import HMSegmentedControl

extension HMSegmentedControl: SegmentedProtocol {
    public var selectedIndex: Int {
        get {
            return Int(selectedSegmentIndex)
        }
        set {
            selectedSegmentIndex = UInt(newValue)
        }
    }

    public var numberOfSegments: Int {
        return sectionTitles?.count ?? 0
    }

    public static func segments(with titles: [String]) -> SegmentedProtocol {
        let segments = HMSegmentedControl(sectionTitles: titles)
        segments.selectionIndicatorLocation = .bottom
        segments.selectionStyle = .fullWidthStripe
        segments.selectionIndicatorHeight = 4.0
        segments.frame = CGRect(x: 0, y: 0, width: 180, height: 44)
        return segments
    }
}
