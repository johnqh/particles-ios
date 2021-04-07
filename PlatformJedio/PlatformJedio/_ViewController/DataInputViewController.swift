//
//  DataInputViewController.swift
//  FieldPresenterLib
//
//  Created by Qiang Huang on 11/21/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import JedioKit
import ParticlesKit
import PlatformParticles
import UIToolkits
import Utilities

open class DataInputViewController: FieldsViewController {
    private var presented: Bool = false
    private var pushed: Bool = false
    @IBInspectable var key: String?
    @IBInspectable var defaultJson: String?
    @IBOutlet public var doneButton: ButtonProtocol? {
        didSet {
            oldValue?.removeTarget()
            doneButton?.addTarget(self, action: #selector(done(_:)))
        }
    }

    @IBOutlet public var cancelButton: ButtonProtocol? {
        didSet {
            oldValue?.removeTarget()
            cancelButton?.addTarget(self, action: #selector(cancel(_:)))
        }
    }

    @IBOutlet var resetButton: ButtonProtocol? {
        didSet {
            oldValue?.removeTarget()
            resetButton?.addTarget(self, action: #selector(reset(_:)))
        }
    }

    override open var entity: ModelObjectProtocol? {
        didSet {
            if let editing = entity as? JsonPersistable {
                let data = DictionaryEntity()
                data.data = editing.json
                self.data = data
            } else {
                self.data = nil
            }
        }
    }

    override open var editingObject: ModelObjectProtocol? {
        return data
    }

    open var data: DictionaryEntity? {
        didSet {
            fieldsEntity.entity = editingObject
        }
    }

    open var fieldInputs: ListInteractor? {
        return self.presenterManager?.listInteractor
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        if interactor == nil {
            if let key = key {
                interactor = LocalEntityCacheInteractor(key: key, default: defaultJson)
            }
        }
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if presented || pushed {
        } else {
            presented = presenting()
            pushed = pushing()
        }
        setupButtons()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        if presented {
            // commit triggered by doneButton
        } else if pushed {
            if popping() {
                commit()
            }
        } else {
            commit()
        }
    }

    open func setupButtons() {
        if presented {
            if doneButton == nil {
                doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
            }
            cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
            navigationItem.rightBarButtonItem = doneButton as? UIBarButtonItem ?? resetButton as? UIBarButtonItem
            navigationItem.leftBarButtonItem = cancelButton as? UIBarButtonItem
        } else {
            doneButton = nil
            cancelButton = nil
            navigationItem.rightBarButtonItem = nil
            navigationItem.leftBarButtonItem = nil
        }
    }

    open func commit() {
        view.endEditing(true)
        var editing = entity as? JsonPersistable
        var json = data?.data ?? [String: Any]()
        if let keys = fieldsEntity.keys {
            for key in keys {
                if json[key] == nil {
                    json[key] = NSNull()
                }
            }
        }
        editing?.json = json
    }

    @IBAction open func done(_ sender: Any?) {
        view.endEditing(true)
        if let error = fieldsEntity.validateInput() {
            let text = (error as NSError).userInfo["message"] as? String ?? "Unknown error"
            if let prompter = PrompterFactory.shared?.prompter() {
                prompter.set(title: text, message: nil, style: .error)
                prompter.prompt([PrompterAction.cancel()])
            }
        } else {
            commit()
            dismiss(sender)
        }
    }

    @IBAction func cancel(_ sender: Any?) {
        dismiss(sender)
    }

    @IBAction open func reset(_ sender: Any?) {
        data?.data = nil
    }
}
