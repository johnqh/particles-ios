//
//  FieldOutputPresenter.swift
//  FieldPresenterLib
//
//  Created by Qiang Huang on 10/15/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import JedioKit
import KVOController
import ParticlesKit
import UIKit
import UIToolkits

@objc public class FieldOutputPresenter: ObjectPresenter, ObjectTableCellPresenterProtocol {
    let kCollectionViewCellHeight: CGFloat = 36.0
    let kItemsPerRow = 2

    internal var field: FieldOutput? {
        return model as? FieldOutput
    }

    @IBInspectable var textCellXib: String?
    @IBInspectable var imageCellXib: String?

    @IBOutlet var titleLabel: LabelProtocol?
    @IBOutlet var subtitleLabel: LabelProtocol?
    @IBOutlet var textLabel: LabelProtocol?
    @IBOutlet var subtextLabel: LabelProtocol?
    @IBOutlet var imageView: ImageViewProtocol?
    @IBOutlet var collectionView: UICollectionView? {
        didSet {
            if collectionView !== oldValue {
                oldValue?.dataSource = nil
                oldValue?.delegate = nil

                collectionView?.dataSource = self
                collectionView?.delegate = self

                if let nib = UINib.safeLoad(xib: textCellXib ?? "text_collection_cell", bundles: Bundle.particles) {
                    collectionView?.register(nib, forCellWithReuseIdentifier: "string")
                }
                if let nib = UINib.safeLoad(xib: imageCellXib ?? "image_collection_cell", bundles: Bundle.particles) {
                    collectionView?.register(nib, forCellWithReuseIdentifier: "image")
                }
                collectionView?.allowsSelection = false
            }
        }
    }

    @objc override open var selectable: Bool {
        return field?.link != nil
    }

    @IBOutlet var collectionViewHeight: NSLayoutConstraint?

    public var entity: ModelObjectProtocol? {
        didSet {
            changeObservation(from: oldValue, to: entity, keyPath: #keyPath(DictionaryEntity.data)) { [weak self] _, _, _ in
                self?.update()
            }
        }
    }

    override public var model: ModelObjectProtocol? {
        didSet {
            changeObservation(from: oldValue, to: field, keyPath: #keyPath(FieldOutput.entity)) { [weak self] _, _, _ in
                if let self = self {
                    self.entity = self.field?.entity
                }
            }

            changeObservation(from: oldValue, to: field, keyPath: #keyPath(FieldOutput.field)) { [weak self] _, _, _ in
                self?.update()
            }
            adjustHeight()
        }
    }

    public var showDisclosure: Bool {
        return selectable
    }

    open func update() {
        titleLabel?.text = field?.title?.localized
        subtitleLabel?.text = field?.subtitle?.localized.replacingOccurrences(of: "<br/>", with: "\n")
        textLabel?.text = field?.text?.localized
        subtextLabel?.text = field?.subtext?.localized
        if let image = field?.image {
            imageView?.image = UIImage.named(image, bundles: Bundle.particles)
        } else if let checked = field?.checked {
            imageView?.image = UIImage.named(checked ? "checked_yes" : "checked_no", bundles: Bundle.particles)
        } else {
            imageView?.image = nil
        }

        collectionView?.reloadData()
    }

    open func adjustHeight() {
        if let _ = field?.strings, let height = collectionViewHeight, let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            let itemcount = field?.strings?.count ?? 0
            var rows = itemcount / kItemsPerRow
            if itemcount % kItemsPerRow != 0 {
                rows += 1
            }
            height.constant = flowLayout.sectionInset.top + flowLayout.sectionInset.bottom + (kCollectionViewCellHeight + flowLayout.minimumLineSpacing) * CGFloat(rows) - flowLayout.minimumLineSpacing
        }
    }
}

extension FieldOutputPresenter: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return field?.strings?.count ?? field?.images?.count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let strings = field?.strings {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "string", for: indexPath)
            if let textCell = cell as? TextCollectionViewCell {
                let text = strings[indexPath.row]
                textCell.text = text.localized
            }
            return cell
        } else if let images = field?.images {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath)
            if let imageCell = cell as? ImageCollectionViewCell {
                let image = images[indexPath.row]
                imageCell.image = image
            }
            return cell
        } else {
            return UICollectionViewCell(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let _ = field?.strings {
            if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
                let width = collectionView.bounds.size.width
                let contentWidth: CGFloat = (width - flowLayout.sectionInset.left - flowLayout.sectionInset.right + flowLayout.minimumInteritemSpacing)
                let itemWidth = contentWidth / CGFloat(kItemsPerRow) - flowLayout.minimumInteritemSpacing

                return CGSize(width: itemWidth, height: kCollectionViewCellHeight)
            } else {
                assertionFailure("only support flow layout here")
                return CGSize(width: 120, height: kCollectionViewCellHeight)
            }
        } else if let _ = field?.images {
            return imageCellSize(collectionView: collectionView)
        } else {
            assertionFailure("only support flow layout here")
            return CGSize(width: 120, height: kCollectionViewCellHeight)
        }
    }

    @objc open func imageCellSize(collectionView: UICollectionView) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
    }
}
