//
//  ResetAppViewController.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 12/23/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import RoutingKit

public class ResetAppViewController: DataInputViewController {
    @IBAction override public func reset(_ sender: Any?) {
        commit()
        Router.shared?.navigate(to: RoutingRequest(path: "/blank"), animated: true, completion: { _, completed in
            if completed {
                Router.shared?.navigate(to: RoutingRequest(path: "/"), animated: true, completion: { _, _ in
                    Router.shared?.navigate(to: RoutingRequest(path: "/authorization/notification"), animated: true, completion: nil)
                })
            }
        })
    }
}
