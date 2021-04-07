//
//  FieldSettingsViewController.swift
//  PlatformJedio
//
//  Created by Qiang Huang on 11/1/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import JedioKit
import RoutingKit
import UIKit
import Utilities

open class FieldSettingsViewController: SettingsViewController {
    @IBOutlet var tableView: UITableView? {
        didSet {
            if tableView !== oldValue {
                oldValue?.dataSource = nil
                oldValue?.delegate = nil
                tableView?.dataSource = self
                tableView?.delegate = self
            }
        }
    }

    @IBInspectable var fieldName: String?

    private var fieldInput: FieldInput? {
        didSet {
            if fieldInput !== oldValue {
                options = fieldInput?.options
            }
        }
    }

    private var options: [[String: Any]]? {
        didSet {
            tableView?.reloadData()
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    open override func sync() {
        fieldInput = findInput()
    }

    private func findInput() -> FieldInput? {
        if let fieldName = fieldName {
            var fieldInput: FieldInput?
            _ = entityFields?.list?.first(where: { (object) -> Bool in
                if let fieldList = object as? FieldListInteractor {
                    _ = fieldList.list?.first(where: { (object2) -> Bool in
                        if let input = object2 as? FieldInput {
                            if input.field?.definition(for: "field")?["field"] as? String == fieldName {
                                fieldInput = input
                                return true
                            }
                        }
                        return false
                    })
                }
                return false
            })
            return fieldInput
        }
        return nil
    }
}

extension FieldSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "option", for: indexPath)
        configure(cell: cell, option: options?[indexPath.row])
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let fieldName = fieldName {
            let option = options?[indexPath.row]
            (fieldInput?.entity as? NSObject)?.setValue(option?["value"], forKey: fieldName)

            tableView.reloadData()
        }
    }

    open func configure(cell: UITableViewCell, option: [String: Any]?) {
        cell.textLabel?.text = parser.asString(option?["text"])
        if let fieldName = fieldName {
            cell.accessoryType = parser.asString((fieldInput?.entity as? NSObject)?.value(forKey: fieldName)) == parser.asString(option?["value"]) ? .checkmark : .none
        } else {
            cell.accessoryType = .none
        }
    }
}
