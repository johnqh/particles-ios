//
//  TableViewListPresenter+Actions.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 10/18/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import ParticlesKit
import RoutingKit
import UIToolkits

extension TableViewListPresenter {
	open func action(request: RoutingRequest?, text: String?, image: String?, color: String?, tint: String?) -> UIContextualAction? {
		return action(request: request, text: text, image: image, color: ColorPalette.shared.color(system: color), tint: ColorPalette.shared.color(system: tint))
 }
	
    open func action(request: RoutingRequest?, text: String?, image: String?, color: UIColor?, tint: UIColor?) -> UIContextualAction? {
        if let request = request {
            let action = UIContextualAction(style: .normal, title: text) {[weak self] _, _, _ in
                self?.tableView?.setEditing(false, animated: true)
                Router.shared?.navigate(to: request, animated: true, completion: { _, _ in
                })
            }
            if let image = image {
                action.image = UIImage.named(image, bundles: Bundle.particles)?.tint(color: tint)
            }
            action.backgroundColor = color
            return action
        }
        return nil
    }
}
