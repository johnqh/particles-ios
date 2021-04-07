//
//  ObjectPresenterTableViewCell.swift
//  PresenterLib
//
//  Created by John Huang on 10/10/18.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import ParticlesKit
import UIKit

@objc open class ObjectPresenterTableViewCell: UITableViewCell, ObjectPresenterProtocol {
    @IBOutlet public var presenterView: UIView?

    public var xib: String? {
        didSet {
            if xib != oldValue {
                presenterView?.removeFromSuperview()
                installPresenterView(xib: xib)
            }
        }
    }

    public var model: ModelObjectProtocol? {
        get { return (presenterView as? ObjectPresenterView)?.model }
        set {
            if let presenter = presenterView as? ObjectPresenterProtocol {
                presenter.model = newValue
                if let selectable = presenter.selectable {
                    selectionStyle = selectable ? .default : .none
                } else {
                    selectionStyle = .none
                }
            } else {
                selectionStyle = .none
            }
        }
    }

    @objc open var selectable: Bool {
        return (presenterView as? ObjectPresenterView)?.selectable ?? false
    }

    open var showDisclosure: Bool? {
        if let presetingView = presenterView as? ObjectPresenterView {
            return presetingView.showDisclosure
        }
        return nil
    }

    open override var isSelected: Bool {
        didSet {
            if isSelected != oldValue {
                (presenterView as? SelectableProtocol)?.isSelected = isSelected
            }
        }
    }

    @objc open dynamic var isFirst: Bool = false {
        didSet {
            (presenterView as? ObjectPresenterView)?.isFirst = isFirst
        }
    }

    @objc open dynamic var isLast: Bool = false {
        didSet {
            (presenterView as? ObjectPresenterView)?.isLast = isLast
        }
    }

    open override func prepareForReuse() {
        model = nil
        isSelected = false
        isFirst = false
        isLast = false
    }

    open func installPresenterView(xib: String?) {
        presenterView = installView(xib: xib, into: contentView)
    }

    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        (presenterView as? SelectableProtocol)?.isSelected = isSelected
    }
}
