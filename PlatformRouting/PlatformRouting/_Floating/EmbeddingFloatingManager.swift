//
//  EmbeddingFloatingManager.swift
//  PlatformRouting
//
//  Created by Qiang Huang on 10/22/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import FloatingPanel
import RoutingKit
import UIAppToolkits
import UIToolkits
import Utilities

open class EmbeddingFloatingManager: FloatingManager, EmbeddingProtocol {
    public weak var embeddingController: RoutingEmbeddingController? {
        return parent as? RoutingEmbeddingController
    }

    public var embeddingContainer: UIView? {
        return embeddingController?.embeddingContainer
    }

    public var floatingContainer: UIView? {
        return embeddingController?.floatingContainer
    }

    public var embedded: UIViewController? {
        didSet {
            if embedded !== oldValue {
                parent?.remove(oldValue)
                installEmbedded()
            }
        }
    }

    public var floating: FloatingPanelController? {
        didSet {
            if floating !== oldValue {
                if let oldValue = oldValue {
                    oldValue.removePanelFromParent(animated: true)
                }
                if let floating = floating, let parent = parent {
                    floating.addPanel(toParent: parent, belowView: nil, animated: true)
                } else {
                    (embedded as? EmbeddedDelegate)?.floatingEdge = 0
                }
            }
        }
    }

    public var floated: UIViewController? {
        didSet {
            if floated !== oldValue {
                float(floated)
            }
        }
    }

    private var debouncer: Debouncer = Debouncer()

    open func embed(_ viewController: UIViewController?, animated: Bool) {
        if let nav = embedded as? UINavigationController {
            if let viewController = viewController {
                nav.pushViewController(viewController, animated: animated)
            }
        } else {
            if animated {
                UIView.animate(embeddingContainer, type: .fade, direction: .none, duration: UIView.defaultAnimationDuration, animations: { [weak self] in
                    self?.embedded = viewController
                }, completion: nil)
            } else {
                embedded = viewController
            }
        }
    }

    open func float(_ viewController: UIViewController?, animated: Bool) {
        floated = viewController
    }

    open func float(_ viewController: UIViewController?) {
        if let viewController = viewController {
            let floater = FloatingPanelController()

            // Initialize FloatingPanelController and add the view
            floater.surfaceView.cornerRadius = 6.0
            if #available(iOS 13.0, *) {
                floater.surfaceView.backgroundColor = UIColor.systemBackground
            } else {
                // Fallback on earlier versions
            }
            floater.surfaceView.shadowHidden = false
            if #available(iOS 13.0, *) {
                floater.surfaceView.backgroundColor = UIColor.systemBackground
            } else {
                // Fallback on earlier versions
            }
            floater.surfaceView.contentInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
            floater.isRemovalInteractionEnabled = false
            floater.modalPresentationStyle = .overCurrentContext

            // Set a content view controller
            floater.set(contentViewController: viewController)
            floater.delegate = self

            floating = floater

            if let floated = viewController as? FloatedDelegate, let scrollView = floated.floatTracking {
                floater.track(scrollView: scrollView)
            }
        } else {
            floating = nil
        }
    }

    override open func floatingPanelDidEndRemove(_ vc: FloatingPanelController) {
        if vc === floating {
            floating = nil
        } else {
            super.floatingPanelDidEndRemove(vc)
        }
    }

    override public func floatingPanelDidChangePosition(_ vc: FloatingPanelController) {
        if vc === floating {
            (floated as? FloatedDelegate)?.position = vc.position
            floatingChanged(vc)
        }
    }

    override public func floatingPanelDidEndDecelerating(_ vc: FloatingPanelController) {
        if vc === floating {
            floatingChanged(vc)
        }
    }

    private func floatingChanged(_ vc: FloatingPanelController) {
        if vc === floating {
            if let handler = debouncer.debounce() {
                handler.run({ [weak self] in
                    if let embedded = self?.embedded {
                        (embedded as? EmbeddedDelegate)?.floatingEdge = vc.surfaceView.frame.origin.y
                    }
                    (self?.floated as? FloatedDelegate)?.floatingChanged()
                }, delay: 0.025)
            }
        }
    }

    override open func dismiss(_ viewController: UIViewController?, animated: Bool) {
        if viewController == floating {
            floating = nil
        } else {
            super.dismiss(viewController, animated: animated)
        }
    }

    open func installEmbedded() {
        parent?.embed(embedded, in: embeddingContainer)
    }
}
