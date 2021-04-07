//
//  EmbeddingProtocols.swift
//  PlatformRouting
//
//  Created by Qiang Huang on 1/20/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import FloatingPanel

public protocol EmbeddedDelegate: class {
    var floatingEdge: CGFloat? { get set }
}

public protocol FloatedDelegate: class {
    var position: FloatingPanelPosition? { get set }
    var floatTracking: UIScrollView? { get }
    func floatingChanged()
}

extension UINavigationController: FloatedDelegate {
    public var position: FloatingPanelPosition? {
        get {
            return (topViewController as? FloatedDelegate)?.position
        }
        set {
            (topViewController as? FloatedDelegate)?.position = newValue
        }
    }

    public var floatTracking: UIScrollView? {
        return (topViewController as? FloatedDelegate)?.floatTracking
    }

    public func floatingChanged() {
        (topViewController as? FloatedDelegate)?.floatingChanged()
    }
}
