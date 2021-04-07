//
//  CachedImageView.swift
//  UIToolkits
//
//  Created by Qiang Huang on 10/29/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import SDWebImage
import UIKit

//  The converted code is limited to 2 KB.
//  Upgrade your plan to remove this limitation.
//
open class CachedImageView: UIImageView {
    public var imageUrl: URL? {
        didSet {
            if imageUrl != oldValue {
                self.sd_setImage(with: imageUrl, completed: nil)
            }
        }
    }

    override open var image: UIImage? {
        get { return super.image }
        set {
            if imageUrl != nil {
                self.set(image: newValue, animated: true)
            } else {
                set(image: newValue)
            }
        }
    }

    open func set(image: UIImage?, animated: Bool) {
        if animated && image != nil && window != nil {
            UIView.animate(self, type: .fade, direction: .none, duration: UIView.defaultAnimationDuration, animations: { [weak self] in
                self?.set(image: image)
            }, completion: nil)
        } else {
            set(image: image)
        }
    }

    open func set(image: UIImage?) {
        super.image = image
    }
}
