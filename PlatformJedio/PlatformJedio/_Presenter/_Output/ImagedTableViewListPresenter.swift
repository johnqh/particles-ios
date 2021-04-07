//
//  ImagedTableViewListPresenter.swift
//  FieldPresenterLib
//
//  Created by Qiang Huang on 11/20/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import KVOController
import ParticlesKit
import PlatformParticles

open class ImagedTableViewListPresenter: TableViewListPresenter {
    open var mediaPresenter: ImagesFieldOutputPresenter? {
        didSet {
            changeObservation(from: oldValue, to: mediaPresenter, keyPath: #keyPath(ImagesFieldOutputPresenter.mediaMode)) { [weak self] _, _, _ in
                if let self = self {
                    self.mediaMode = self.mediaPresenter?.mediaMode ?? .normal
                }
            }
        }
    }

    open var mediaMode: MediaMode = .normal {
        didSet {
            if mediaMode != oldValue {
                switch mediaMode {
                case .normal:
                    mediaPresenter?.fullScreenLayout?.constant = 0

                case .cards, .fullScreen:
                    mediaPresenter?.fullScreenLayout?.constant = self.view?.frame.size.height ?? 320
                }
            }
            tableView?.beginUpdates()
            tableView?.endUpdates()
            mediaPresenter?.collectionView?.collectionViewLayout.invalidateLayout()
        }
    }

    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let presenterCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ObjectPresenterTableViewCell, let view = presenterCell.presenterView as? ObjectPresenterView, let presenter = view.presenter as? ImagesFieldOutputPresenter {
            mediaPresenter = presenter
        }
        return cell
    }
}
