//
//  SignatureViewController.swift
//  UIToolkits
//
//  Created by Qiang Huang on 11/28/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import SwiftSignatureView
import Utilities

public protocol SignatureViewControllerDelegate: NSObjectProtocol {
    func signatureViewController(_ signatureViewController: SignatureViewController, signed: String)
}

open class SignatureViewController: UIViewController {
    public weak var delegate: SignatureViewControllerDelegate?
    @IBInspectable var acknowledgeText: String?
    @IBOutlet var signatureView: LegacySwiftSignatureView? {
        didSet {
            if signatureView !== oldValue {
                oldValue?.delegate = nil
                signatureView?.delegate = self
            }
        }
    }

    @IBOutlet var acknowledgeLabel: UILabel?

    @IBOutlet var uploadingView: UIView?
    @IBOutlet var uploadingProgress: UIProgressView?

    @IBOutlet var doneButton: ButtonProtocol? {
        didSet {
            if doneButton !== oldValue {
                oldValue?.removeTarget()
                doneButton?.addTarget(self, action: #selector(done(_:)))
                (doneButton as? UIButton)?.isEnabled = false
            }
        }
    }

    open var uploading: Bool = false {
        didSet {
            if uploading != oldValue {
                uploadingView?.visible = uploading
            }
        }
    }

    open var imageUrl: String? {
        didSet {
            if imageUrl != oldValue {
                if let imageUrl = imageUrl {
                    if let location = LocationProvider.shared?.location {
                        let lat = location.coordinate.latitude
                        let lng = location.coordinate.longitude
                        image = "\(imageUrl)@\(lat)/\(lng)"
                    } else {
                        image = imageUrl
                    }
                } else {
                    image = nil
                }
            }
        }
    }

    open var image: String? {
        didSet {
            if image != oldValue {
                (doneButton as? UIButton)?.isEnabled = (image != nil)
            }
        }
    }

    @IBOutlet @objc dynamic var uploader: ImageUploaderProtocol? {
        didSet {
            changeObservation(from: oldValue, to: uploader, keyPath: #keyPath(ImageUploaderProtocol.uploading)) { [weak self] _, _, _ in
                self?.uploadingChanged()
            }
            changeObservation(from: oldValue, to: uploader, keyPath: #keyPath(ImageUploaderProtocol.progress)) { [weak self] _, _, _ in
                self?.progressChanged()
            }
        }
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let acknowledgeText = acknowledgeText, let acknowledgeLabel = acknowledgeLabel {
            let date = Date()
            let dateText = date.localDateString
            let text = acknowledgeText.replacingOccurrences(of: "<date>", with: dateText)
            acknowledgeLabel.text = text
        }
    }

    open func uploadingChanged() {
        uploadingView?.visible = uploader?.uploading ?? false
    }

    open func progressChanged() {
        uploadingProgress?.progress = uploader?.progress ?? 0.0
    }

    open func upload(image: UIImage?, completion: UploadCompletion?) {
        if let image = image {
            uploader?.upload(image: image, location: LocationProvider.shared?.location, completion: completion)
        }
    }

    @IBAction func done(_ sender: Any?) {
        if let image = image {
            delegate?.signatureViewController(self, signed: image)
            dismiss(sender)
        } else {
            ErrorInfo.shared?.info(title: "Please obtain signature", message: nil, error: nil)
        }
    }

    private var signedDebouncer: Debouncer = Debouncer()

    open func signed(image: UIImage?) {
        let handler = signedDebouncer.debounce()
        handler?.run({ [weak self] in
            if let self = self {
                if let image = image {
                    self.upload(image: image) { [weak self] imageUrl, error in
                        if let error = error {
                            ErrorInfo.shared?.info(title: "Failed to upload signature", message: nil, error: error)
                        } else {
                            Tracking.shared?.path("/upload_successful", data: nil)
                            RatingService.shared?.add(points: 1)
                            self?.imageUrl = imageUrl
                        }
                    }
                }
            }
        }, delay: 0.25)
    }
}

extension SignatureViewController: SwiftSignatureViewDelegate {
    public func swiftSignatureViewDidDrawGesture(_ view: ISignatureView, _ tap: UIGestureRecognizer) {
        signed(image: view.getCroppedSignature() ?? view.signature)
    }

    public func swiftSignatureViewDidDraw(_ view: ISignatureView) {
        signed(image: view.getCroppedSignature() ?? view.signature)
    }
}
