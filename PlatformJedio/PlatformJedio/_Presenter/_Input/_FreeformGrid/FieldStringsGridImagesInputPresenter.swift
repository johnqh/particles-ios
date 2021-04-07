//
//  FieldStringsGridImagesInputPresenter.swift
//  PlatformJedio
//
//  Created by Qiang Huang on 11/28/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import ParticlesKit
import RoutingKit
import UIToolkits
import Utilities

@objc open class FieldStringsGridImagesInputPresenter: FieldStringsGridInputPresenter {
    public var imageAddCell: ImageAddCollectionViewCell?
    @IBInspectable var addImageCellXib: String?
    @IBInspectable var imageRoute: String?
    open var actionCellXib: String {
        return addImageCellXib ?? "image_action_cell"
    }

    override open var selectionCellXib: String {
        return cellXib ?? "image_collection_cell"
    }

    @IBOutlet override var collectionView: UICollectionView? {
        didSet {
            if collectionView !== oldValue {
                if let nib = UINib.safeLoad(xib: actionCellXib, bundles: Bundle.particles) {
                    collectionView?.register(nib, forCellWithReuseIdentifier: "action")
                }
            }
        }
    }

    override public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellHeight, height: cellHeight)
    }

    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "action", for: indexPath)
            imageAddCell = cell as? ImageAddCollectionViewCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            if let imageCell = cell as? GridImageCollectionViewCell {
                imageCell.presenter = self
                imageCell.image = field?.strings?.at(indexPath.row - 1)
                return cell
            }
            return cell
        }
    }

    override open func addString() {
        Router.shared?.navigate(to: RoutingRequest(path: imageRoute ?? "/action/photos/add"), animated: true, completion: nil)
    }

    public func add(image: String) {
        var strings = field?.strings ?? [String]()
        if !strings.contains(image) {
            strings.append(image)
            field?.strings = strings
            collectionView?.reloadData()
        }
    }

    public func remove(image: String) {
        if var strings = field?.strings {
            strings.removeAll { (string) -> Bool in
                string == image
            }
            field?.strings = strings
            collectionView?.reloadData()
        }
    }
}
