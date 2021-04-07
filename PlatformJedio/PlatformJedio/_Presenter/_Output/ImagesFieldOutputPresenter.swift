//
//  ImagesFieldOutputPresenter.swift
//  FieldPresenterLib
//
//  Created by Qiang Huang on 11/20/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import Foundation

@objc public enum MediaMode: Int {
    case normal
    case cards
    case fullScreen
}

@objc public class ImagesFieldOutputPresenter: FieldOutputPresenter {
    @IBOutlet var fullScreenLayout: NSLayoutConstraint?

    override var collectionView: UICollectionView? {
        didSet {
            collectionView?.allowsSelection = true
        }
    }

    @objc public dynamic var mediaMode: MediaMode = .normal {
        didSet {
            if mediaMode != oldValue {
                layoutCollectionView()
            }
        }
    }

    private var imageCellSize: CGSize?
    private var selectionIndexPath: IndexPath?

    public func layoutCollectionView() {
        switch mediaMode {
        case .normal:
            collectionView?.showsHorizontalScrollIndicator = true
            collectionView?.showsVerticalScrollIndicator = false
            #if _iOS
                collectionView?.isPagingEnabled = true
            #endif

        case .cards:
            collectionView?.showsHorizontalScrollIndicator = false
            collectionView?.showsVerticalScrollIndicator = true
            #if _iOS
                collectionView?.isPagingEnabled = false
            #endif

        case .fullScreen:
            collectionView?.showsHorizontalScrollIndicator = true
            collectionView?.showsVerticalScrollIndicator = false
            #if _iOS
                collectionView?.isPagingEnabled = true
            #endif
        }
        collectionView?.collectionViewLayout.invalidateLayout()

        switch mediaMode {
        case .normal:
            (collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal

        case .cards:
            (collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .vertical

        case .fullScreen:
            (collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal
        }
        if let selectionIndexPath = selectionIndexPath {
            collectionView?.scrollToItem(at: selectionIndexPath, at: .top, animated: false)
            collectionView?.scrollToItem(at: selectionIndexPath, at: .left, animated: false)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectionIndexPath = indexPath
        switchMediaMode()
    }

    @objc open override func imageCellSize(collectionView: UICollectionView) -> CGSize {
        switch mediaMode {
        case .normal:
            imageCellSize = super.imageCellSize(collectionView: collectionView)
            return imageCellSize!

        case .cards:
            return imageCellSize ?? super.imageCellSize(collectionView: collectionView)

        case .fullScreen:
            return super.imageCellSize(collectionView: collectionView)
        }
    }

    open func switchMediaMode() {
        switch mediaMode {
        case .normal:
            mediaMode = .cards

        case .cards:
            mediaMode = .fullScreen

        case .fullScreen:
            mediaMode = .normal
        }
    }
}
