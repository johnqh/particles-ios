//
//  UIViewController+App.swift
//  UIAppToolkits
//
//  Created by Qiang Huang on 1/25/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import UIKit

public extension UIViewController {
    func bringEditingToView() {
        if let textInput = UIResponder.current as? (UIView & UITextInput) {
            if let cell: UITableViewCell = textInput.parent(), let tableView: UITableView = cell.parent(), let indexPath = tableView.indexPath(for: cell) {
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
}
