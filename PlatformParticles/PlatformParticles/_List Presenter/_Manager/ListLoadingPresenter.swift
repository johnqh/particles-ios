//
//  File.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 12/23/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import KVOController
import ParticlesKit
import UIToolkits

@objc open class ListLoadingPresenter: ListPresenter {
    @IBOutlet var view: ViewProtocol?
    @IBOutlet var spinner: SpinnerProtocol?
    @IBOutlet var label: LabelProtocol?
    @IBInspectable public var loadingText: String?
    @IBInspectable public var noDataText: String?

    open override var interactor: ListInteractor? {
        didSet {
            if interactor !== oldValue {
                let loadingKeyPath = #keyPath(ListInteractor.loading)
                let itemsKeyPath = #keyPath(ListInteractor.list)
                kvoController.unobserve(interactor, keyPath: loadingKeyPath)
                kvoController.unobserve(interactor, keyPath: itemsKeyPath)
                kvoController.observe(interactor, keyPath: loadingKeyPath, options: [.initial]) { [weak self] _, _, _ in
                    self?.updateLoading()
                }
                kvoController.observe(interactor, keyPath: itemsKeyPath, options: [.initial]) { [weak self] _, _, _ in
                    self?.updateLoading()
                }
            }
        }
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        updateLoading()
    }

    open func updateLoading() {
        if let items = interactor?.list {
            if items.count > 0 {
                view?.visible = false
            } else {
                spinner?.spinning = false
                label?.text = noDataText?.localized
                view?.visible = true
            }
        } else {
            spinner?.spinning = true
            label?.text = loadingText?.localized
            view?.visible = true
        }
    }
}
