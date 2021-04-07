//
//  UIButton+Layout.swift
//  UIToolkits
//
//  Created by Qiang Huang on 11/23/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import UIKit

public extension UIButton {
    func centerImageAndButton(_ gap: CGFloat, imageOnTop: Bool) {
        guard let imageView = self.currentImage,
            let titleLabel = self.titleLabel?.text else { return }

        let sign: CGFloat = imageOnTop ? 1 : -1
        titleEdgeInsets = UIEdgeInsets(top: (imageView.size.height + gap) * sign, left: -imageView.size.width, bottom: 0, right: 0)

        let titleSize = titleLabel.size(withAttributes: [NSAttributedString.Key.font: self.titleLabel!.font!])
        imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + gap) * sign, left: 0, bottom: 0, right: -titleSize.width)
    }

    func setInsets(forContentPadding contentPadding: UIEdgeInsets, imageTitlePadding: CGFloat) {
        contentEdgeInsets = UIEdgeInsets(top: contentPadding.top, left: contentPadding.left, bottom: contentPadding.bottom, right: contentPadding.right + imageTitlePadding)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: imageTitlePadding, bottom: 0, right: -imageTitlePadding)
    }
}
