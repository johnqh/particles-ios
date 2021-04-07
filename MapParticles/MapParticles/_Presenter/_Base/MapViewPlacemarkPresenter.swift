//
//  MapViewPlacemarkPresenter.swift
//  MapParticles
//
//  Created by Qiang Huang on 8/29/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import MapKit
import ParticlesKit
import PlatformParticles
import UIToolkits

open class MapViewPlacemarkPresenter: ObjectPresenter {
    @IBOutlet public var circleView: UIView?
    @IBOutlet public var imageView: CachedImageView?
    @IBOutlet public var titleLabel: LabelProtocol?

    public var placemark: PlacemarkProtocol? {
        return model as? PlacemarkProtocol
    }

    override open var model: ModelObjectProtocol? {
        didSet {
            if model !== oldValue {
                updateColor()
                updateImage()
                updateTitle()
            }
        }
    }

    private func updateColor() {
        circleView?.backgroundColor = ColorPalette.shared.color(text: placemark?.color)
    }

    private func updateImage() {
        imageView?.imageUrl = placemark?.imageUrl
    }

    private func updateTitle() {
        titleLabel?.text = placemark?.placemarkName
    }
}

extension MapViewPlacemarkPresenter: MapAnnotationPresenterProtocol {
    public var showCallout: Bool {
        return true
    }

    public func accessoryButton() -> UIButton? {
        if let image = UIImage.named("icon_disclose", bundles: Bundle.particles) {
            let button = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 28.0, height: 28.0))
            button.setImage(image, for: .normal)
            return button
        }
        return nil
    }
}
