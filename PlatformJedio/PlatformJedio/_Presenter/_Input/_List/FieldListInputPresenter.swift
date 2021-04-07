//
//  FieldListInputPresenter.swift
//  PlatformJedio
//
//  Created by Qiang Huang on 11/28/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import JedioKit
import KVOController
import ParticlesKit
import UIToolkits
import Utilities

@objc open class FieldListInputPresenter: FieldInputPresenter {
    var options: [[String: Any]]? {
        didSet {
            tableView?.reloadData()
        }
    }

    open var selectionCellXib: String {
        return "text_table_cell"
    }

    override open var model: ModelObjectProtocol? {
        didSet {
            changeObservation(from: oldValue, to: field, keyPath: #keyPath(FieldInput.field)) { [weak self] _, _, _ in
                if let self = self {
                    self.definition = self.field?.field as? FieldInputDefinition
                }
            }
        }
    }

    private var definition: FieldInputDefinition? {
        didSet {
            changeObservation(from: oldValue, to: definition, keyPath: #keyPath(FieldInputDefinition.options)) { [weak self] _, _, _ in
                if let self = self {
                    self.options = self.definition?.options
                }
            }
        }
    }

    @IBOutlet var tableView: UITableView? {
        didSet {
            if tableView !== oldValue {
                oldValue?.dataSource = nil
                oldValue?.delegate = nil

                tableView?.dataSource = self
                tableView?.delegate = self

                if let nib = UINib.safeLoad(xib: selectionCellXib, bundles: Bundle.particles) {
                    tableView?.register(nib, forCellReuseIdentifier: "cell")
                }
                tableView?.allowsSelection = true
            }
        }
    }

    @IBOutlet var collectionViewHeight: NSLayoutConstraint?

    override open func update() {
        super.update()
        if let tableView = tableView, let options = field?.options {
            tableView.reloadData()
            for (index, option) in options.enumerated() {
                if isSelected(value: option["value"]) {
                    let indexPath = IndexPath(row: index, section: 0)
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
                }
            }
        }
    }

    open func isSelected(value: Any?) -> Bool {
        return false
    }

    open func select(value: Any?) {
    }

    open func deselect(value: Any?) {
    }
}

extension FieldListInputPresenter: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return field?.options?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let textCell = cell as? TextTableViewCell {
            textCell.title = parser.asString(field?.options?[indexPath.row]["text"])?.localized
            return cell
        }
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let value = field?.options?[indexPath.row]["value"]
        select(value: value)
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let value = field?.options?[indexPath.row]["value"]
        deselect(value: value)
    }
}
