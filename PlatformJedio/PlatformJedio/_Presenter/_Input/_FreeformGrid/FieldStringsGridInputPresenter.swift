//
//  FieldStringsGridInputPresenter.swift
//  PlatformJedio
//
//  Created by Qiang Huang on 11/28/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import KVOController
import ParticlesKit
import UIToolkits
import Utilities

@objc open class FieldStringsGridInputPresenter: FieldInputPresenter {
    @IBInspectable var cellXib: String?
    @IBInspectable var itemsPerRow: Int = 0
    @IBInspectable var cellHeight: CGFloat = 36.0

    var validatedItemsPerRow: Int {
        return itemsPerRow == 0 ? 2 : itemsPerRow
    }

    open var selectionCellXib: String {
        return cellXib ?? "text_collection_cell"
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

    open func addString() {
    }
}

extension FieldStringsGridInputPresenter: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + (field?.strings?.count ?? 0)
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
        return indexPath.row == 0
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            addString()
        }
    }

    public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    }
}
