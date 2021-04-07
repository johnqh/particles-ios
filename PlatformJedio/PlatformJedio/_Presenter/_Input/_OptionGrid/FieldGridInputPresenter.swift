//
//  FieldOutputPresenter.swift
//  FieldPresenterLib
//
//  Created by Qiang Huang on 10/15/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import KVOController
import ParticlesKit
import UIToolkits
import Utilities

@objc open class FieldGridInputPresenter: FieldInputPresenter {
    @IBInspectable var itemsPerRow: Int = 0
    @IBInspectable var cellXib: String?
    @IBInspectable var cellHeight: CGFloat = 36.0

    var validatedItemsPerRow: Int {
        return itemsPerRow == 0 ? 2 : itemsPerRow
    }

    var options: [[String: Any]]?

    open var selectionCellXib: String {
        return cellXib ?? "text_collection_cell"
    }

    override open var model: ModelObjectProtocol? {
        didSet {
            options = field?.options
        }
    }

    @IBOutlet var collectionView: UICollectionView? {
        didSet {
            if collectionView !== oldValue {
                oldValue?.dataSource = nil
                oldValue?.delegate = nil

                collectionView?.dataSource = self
                collectionView?.delegate = self

                if let nib = UINib.safeLoad(xib: selectionCellXib, bundles: Bundle.particles) {
                    collectionView?.register(nib, forCellWithReuseIdentifier: "cell")
                }
                collectionView?.allowsSelection = true
            }
        }
    }

    @IBOutlet var collectionViewHeight: NSLayoutConstraint?

    override open func update() {
        super.update()
        if let collectionView = collectionView, let options = field?.options {
            collectionView.reloadData()
            for (index, option) in options.enumerated() {
                if isSelected(value: option["value"]) {
                    let indexPath = IndexPath(row: index, section: 0)
                    collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                }
            }
        }
        adjustHeight()
    }

    open func adjustHeight() {
        if let height = collectionViewHeight, let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            let itemcount = field?.options?.count ?? 0
            var rows = itemcount / validatedItemsPerRow
            if itemcount % validatedItemsPerRow != 0 {
                rows += 1
            }
            height.constant = flowLayout.sectionInset.top + flowLayout.sectionInset.bottom + (cellHeight + flowLayout.minimumLineSpacing) * CGFloat(rows) - flowLayout.minimumLineSpacing
        }
    }

    open func isSelected(value: Any?) -> Bool {
        return false
    }

    open func select(value: Any?) {
    }

    open func deselect(value: Any?) {
    }
}

extension FieldGridInputPresenter: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return field?.options?.count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let textCell = cell as? TextCollectionViewCell {
            textCell.text = parser.asString(field?.options?[indexPath.row]["text"])?.localized
            return cell
        }
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            let width = collectionView.bounds.size.width
            let contentWidth: CGFloat = (width - flowLayout.sectionInset.left - flowLayout.sectionInset.right + flowLayout.minimumInteritemSpacing)
            let itemWidth = contentWidth / CGFloat(validatedItemsPerRow) - flowLayout.minimumInteritemSpacing

            return CGSize(width: itemWidth, height: cellHeight)
        } else {
            assertionFailure("only support flow layout here")
            return CGSize(width: 120, height: cellHeight)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let value = field?.options?[indexPath.row]["value"]
        return !isSelected(value: value)
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let value = field?.options?[indexPath.row]["value"]
        select(value: value)
    }

    public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        let value = field?.options?[indexPath.row]["value"]
        return isSelected(value: value)
    }

    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let value = field?.options?[indexPath.row]["value"]
        deselect(value: value)
    }
}
