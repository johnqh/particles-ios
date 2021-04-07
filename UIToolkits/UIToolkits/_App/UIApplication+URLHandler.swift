//
//  UIApplication+URLHandler.swift
//  UIAppToolkits
//
//  Created by Qiang Huang on 12/30/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import UIKit
import Utilities

extension UIApplication: URLHandlerProtocol {
    public func open(_ url: URL, completionHandler completion: ((Bool) -> Void)?) {
        open(url, options: [:], completionHandler: completion)
    }
}
