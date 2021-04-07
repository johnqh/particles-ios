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
import UIToolkits

@objc open class FieldInputPresenter: ObjectPresenter {
    open var field: FieldInput? {
        return model as? FieldInput
    }

    @IBOutlet var titleLabel: LabelProtocol?
    @IBOutlet var subtitleLabel: LabelProtocol?
    @IBOutlet var textLabel: LabelProtocol?
    @IBOutlet var imageView: ImageViewProtocol?

    override open var model: ModelObjectProtocol? {
        didSet {
            changeObservation(from: oldValue, to: field, keyPath: #keyPath(FieldInput.field)) { [weak self] _, _, _ in
                self?.update()
            }
            changeObservation(from: oldValue, to: field, keyPath: #keyPath(FieldInput.entity)) { [weak self] _, _, _ in
                if let self = self {
                    self.entity = self.field?.entity
                }
            }
        }
    }

    @objc open dynamic var entity: ModelObjectProtocol? {
        didSet {
            changeObservation(from: oldValue, to: entity, keyPath: #keyPath(DictionaryEntity.data)) { [weak self] _, _, _ in
                self?.update()
            }
        }
    }

    open func update() {
        titleLabel?.text = field?.title?.localized
        subtitleLabel?.text = field?.subtitle?.localized
        if let image = field?.image {
            imageView?.image = UIImage.named(image, bundles: Bundle.particles)
        } else {
            imageView?.image = nil
        }
    }
}
