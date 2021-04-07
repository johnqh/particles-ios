//
//  ThemeViewController.swift
//  ThemeKit
//
//  Created by Qiang Huang on 4/21/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import UIKit
import UIToolkits
import Utilities

open class ThemeViewController: UIViewController {
    @IBOutlet var tableView: UITableView? {
        didSet {
            if tableView != oldValue {
                oldValue?.dataSource = nil
                oldValue?.delegate = nil
                tableView?.dataSource = self
                tableView?.delegate = self
            }
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.reloadData()
    }

    @IBAction func cancel(_ sender: Any?) {
        dismiss(sender)
    }
}

extension ThemeViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ThemeManager.shared?.themes?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "theme", for: indexPath)
        configure(cell: cell, theme: ThemeManager.shared?.themes?[indexPath.row])
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        ThemeManager.shared?.index = indexPath.row
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.dismiss(self)
        }
    }

    open func configure(cell: UITableViewCell, theme: UITheme?) {
        if let theme = theme {
            cell.textLabel?.text = theme.name?.localized
            cell.textLabel?.textColor = (theme === ThemeManager.shared?.current) ? UIColor.black : UIColor.darkGray
            cell.accessoryType = (theme === ThemeManager.shared?.current) ? .checkmark : .none
        }
    }
}
