//
//  ParallaxObjectPresenterTableViewCell.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 12/24/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import Masonry
import UIToolkits

@objc open class ParallaxObjectPresenterTableViewCell: ObjectPresenterTableViewCell {
    @IBOutlet var canvasView: UIView?
    @IBOutlet var canvasCenter: NSLayoutConstraint?

    open override func installPresenterView(xib: String?) {
        presenterView = installView(xib: xib, into: canvasView ?? contentView)
    }

    open func parallax(animated: Bool) {
        if let canvasView = canvasView, let canvasCenter = canvasCenter, let tableview: UITableView = self.parent(), let superview = tableview.superview {
            let cellFrameInTable = tableview.convert(frame, to: superview)
            let cellCenter = cellFrameInTable.origin.y + cellFrameInTable.size.height / 2
            let ratio = cellCenter / (tableview.frame.size.height / 2) - 1
            canvasCenter.constant = (frame.size.height - canvasView.frame.size.height) / 2 * ratio
            if animated {
                UIView.animate(withDuration: UIView.defaultAnimationDuration) {
                    self.layoutIfNeeded()
                }
            }
        }
    }
}
