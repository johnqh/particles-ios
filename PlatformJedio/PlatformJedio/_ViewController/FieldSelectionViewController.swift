//
//  FieldSelectionViewController.swift
//  PlatformJedio
//
//  Created by Qiang Huang on 11/28/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import JedioKit
import ParticlesKit
import PlatformParticles
import UIToolkits
import Utilities

open class FieldSelectionViewController: UIViewController {
    @IBOutlet var cancelButton: UIBarButtonItem? {
        didSet {
            if cancelButton !== oldValue {
                oldValue?.removeTarget()
                cancelButton?.addTarget(self, action: #selector(dismiss(_:)))
            }
        }
    }

    @IBOutlet var presenter: FieldListTextInputPresenter? {
        didSet {
            if presenter !== oldValue {
                presenter?.model = input
            }
        }
    }

    override open var isSearching: Bool {
        didSet {
            if isSearching != oldValue {
                updateSearch()
            }
        }
    }

    public var input: FieldInput? {
        didSet {
            if input !== oldValue {
                presenter?.model = input
            }
            changeObservation(from: oldValue, to: input, keyPath: #keyPath(FieldInput.field)) { [weak self] _, _, _ in
                if let self = self {
                    self.definition = self.input?.field as? FieldInputDefinition
                }
            }
            changeObservation(from: oldValue, to: input, keyPath: #keyPath(FieldInput.entity)) { [weak self] _, _, _ in
                if let self = self {
                    self.entity = self.input?.entity as? DictionaryEntity
                }
            }
        }
    }

    public var definition: FieldInputDefinition? {
        didSet {
            if definition !== oldValue {
                options = definition?.options
                updateOptions()
            }
        }
    }

    private var options: [[String: Any]]?

    private var filteredOptions: [[String: Any]]? {
        didSet {
            definition?.options = filteredOptions
        }
    }

    override open var searchText: String? {
        didSet {
            if searchText != oldValue {
                updateOptions()
            }
        }
    }

    public var entity: DictionaryEntity? {
        didSet {
            changeObservation(from: oldValue, to: entity, keyPath: #keyPath(DictionaryEntity.data)) { [weak self] _, _, _ in
                self?.dataChanged()
            }
        }
    }

    private var ready: Bool = false

    public static func select(input: FieldInput?) {
        if let vc = UIViewController.load(storyboard: "FieldSelection") as? FieldSelectionViewController {
            vc.input = input
            let nav = UIViewController.navigation(with: vc)
            ViewControllerStack.shared?.topmost()?.present(nav, animated: true, completion: nil)
        }
    }

    private var dataChangeDebouncer: Debouncer = Debouncer()

    private var optionDebouncer: Debouncer = Debouncer()
    func updateOptions() {
        let handler = optionDebouncer.debounce()
        handler?.run({ [weak self] in
            self?.reallyUpdateOptions()
        }, delay: 0.25)
    }

    func reallyUpdateOptions() {
        if let searchText = searchText?.trim()?.lowercased(), let options = options {
            var filtered = [[String: Any]]()
            for option in options {
                if let text = parser.asString(option["text"]) {
                    if text.lowercased().contains(searchText) {
                        filtered.append(option)
                    }
                }
            }
            filteredOptions = filtered
        } else {
            filteredOptions = options
        }
    }

    func dataChanged() {
        if ready {
            let handler = dataChangeDebouncer.debounce()
            handler?.run({ [weak self] in
                self?.dismiss(nil)
            }, delay: 0.01)
        }
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ready = true
        updateSearch()
    }

    private func updateSearch() {
        if let searchView = searchView {
            navigationItem.titleView = searchView
        }
        navigationItem.rightBarButtonItem = cancelButton
    }
}
