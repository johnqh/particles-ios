//
//  GraphingListPresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 3/6/21.
//  Copyright © 2021 Qiang Huang. All rights reserved.
//

import Charts
import Differ
import ParticlesKit
import UIToolkits
import Utilities

open class GraphingListPresenter: NativeListPresenter {
    @IBInspectable public dynamic var label: String?
    @IBInspectable public dynamic var color: UIColor?

    @objc public dynamic var graphing: [ChartDataEntry]?

    override open func filter(items: [ModelObjectProtocol]?) -> [ModelObjectProtocol]? {
        return items?.compactMap({ (obj) -> ModelObjectProtocol? in
            obj as? GraphingObjectProtocol
        }).sorted(by: { (item1, item2) -> Bool in
            let graph1 = item1 as? GraphingObjectProtocol
            let graph2 = item2 as? GraphingObjectProtocol
            if let x1 = graph1?.x, let x2 = graph2?.x {
                return x1 < x2
            } else {
                return true
            }
        })
    }

    override open func update() {
        if graphing != nil {
            update(move: false)
        } else {
            current = pending
            refresh(animated: false, completion: nil)
        }
    }

    override open func update(diff: Diff, patches: [Patch<ModelObjectProtocol>], current: [ModelObjectProtocol]?) {
        for change in patches {
            switch change {
            case let .deletion(index):
                graphing?.remove(at: index)

            case let .insertion(index: index, element: element):
                if let entry = graphing(object: element) {
                    graphing?.insert(entry, at: index)
                }
            }
        }
    }

    open func graphing(object: ModelObjectProtocol?) -> ChartDataEntry? {
        if let graphing = object as? GraphingObjectProtocol, let x = graphing.x, let y = graphing.y {
            return ChartDataEntry(x: Double(x), y: Double(y))
        }
        return nil
    }

    override open func refresh(animated: Bool, completion: (() -> Void)?) {
        graphing = current?.compactMap({ (obj) -> ChartDataEntry? in
            graphing(object: obj)
        })
        completion?()
    }
}
