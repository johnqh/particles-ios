//
//  ObjectPresenterCollectionViewCell.swift
//  PresenterLib
//
//  Created by Qiang Huang on 10/10/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import ParticlesKit
import UIKit

@objc public class ObjectPresenterCollectionViewCell: UICollectionViewCell, ObjectPresenterProtocol {
    @IBOutlet public var presenterView: UIView?

    public var xib: String? {
        didSet {
            if xib != oldValue {
                presenterView?.removeFromSuperview()
                presenterView = installView(xib: xib, into: contentView)
            }
        }
    }

    public var model: ModelObjectProtocol? {
        get { return (presenterView as? ObjectPresenterView)?.model }
        set { (presenterView as? ObjectPresenterView)?.model = newValue }
    }

    @objc open var selectable: Bool {
        return (presenterView as? ObjectPresenterView)?.selectable ?? false
    }

    public override func awakeFromNib() {
        super.awakeFromNib()

        if #available(iOS 12.0, *) {
            contentView.translatesAutoresizingMaskIntoConstraints = false

            // Code below is needed to make the self-sizing cell work when building for iOS 12 from Xcode 10.0:
            let leftConstraint = contentView.leftAnchor.constraint(equalTo: leftAnchor)
            let rightConstraint = contentView.rightAnchor.constraint(equalTo: rightAnchor)
            let topConstraint = contentView.topAnchor.constraint(equalTo: topAnchor)
            let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
            NSLayoutConstraint.activate([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
        }
    }

    public override func prepareForReuse() {
        model = nil
    }
}
