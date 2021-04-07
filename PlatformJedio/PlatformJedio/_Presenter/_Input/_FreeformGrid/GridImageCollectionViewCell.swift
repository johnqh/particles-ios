//
//  GridImageCollectionViewCell.swift
//  PlatformJedio
//
//  Created by Qiang Huang on 11/28/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import UIToolkits

public class GridImageCollectionViewCell: ImageCollectionViewCell {
    public weak var presenter: FieldStringsGridImagesInputPresenter?
    @IBOutlet var deleteButton: UIButton? {
        didSet {
            if deleteButton !== oldValue {
                oldValue?.removeTarget()
                deleteButton?.addTarget(self, action: #selector(delete(_:)))
            }
        }
    }

    @IBAction override public func delete(_ sender: Any?) {
        if let image = image {
            presenter?.remove(image: image)
        }
    }
}
