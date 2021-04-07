//
//  NVActivityIndicatorView+Spinner.swift
//  UIAppToolkits
//
//  Created by Qiang Huang on 12/30/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import NVActivityIndicatorView
import UIKit

extension NVActivityIndicatorView: SpinnerProtocol {
    public var spinning: Bool {
        get { return isAnimating }
        set {
            if newValue {
                startAnimating()
            } else {
                stopAnimating()
            }
        }
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        type = .circleStrokeSpin
    }
}
