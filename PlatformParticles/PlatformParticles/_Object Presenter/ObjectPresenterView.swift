//
//  ObjectPresenterView.swift
//  PresenterLib
//
//  Created by John Huang on 10/10/18.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import ParticlesKit
import UIKit
import UIToolkits

@objc open class ObjectPresenterView: UIView, ObjectPresenterProtocol, SelectableProtocol {
    @IBOutlet public var presenter: ObjectPresenter?

    public var model: ModelObjectProtocol? {
        get { return presenter?.model }
        set { presenter?.model = newValue }
    }

    @objc open var selectable: Bool {
        return presenter?.selectable ?? false
    }

    open var showDisclosure: Bool? {
        if let tableCellPresenter = presenter as? ObjectTableCellPresenterProtocol {
            return tableCellPresenter.showDisclosure
        }
        return nil
    }

    public var isSelected: Bool = false {
        didSet {
            if let selectable = (presenter as? SelectableProtocol) {
                selectable.isSelected = isSelected
            }
        }
    }

    public var isFirst: Bool = false {
        didSet {
            presenter?.isFirst = isFirst
        }
    }

    public var isLast: Bool = false {
        didSet {
            presenter?.isLast = isLast
        }
    }
}

extension ObjectPresenter {
    open func updateLayout(view: UIView?) {
        if let view = view, model != nil {
            if let collectionView: UICollectionView = view.parent() {
                view.layoutIfNeeded()
                DispatchQueue.main.async {
                    collectionView.collectionViewLayout.invalidateLayout()
                }
            } else if let tableView: UITableView = view.parent() {
                if let uxTableView = tableView as? UXTableView {
                    uxTableView.updateLayout()
                } else {
                    DispatchQueue.main.async {
                        tableView.beginUpdates()
                        tableView.endUpdates()
                    }
                }
            } else {
                view.layoutIfNeeded()
            }
        }
    }
}
