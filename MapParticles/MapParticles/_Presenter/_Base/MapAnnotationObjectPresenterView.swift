//
//  MapAnnotationObjectPresenterView.swift
//  PresenterLib
//
//  Created by John Huang on 11/27/18.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import MapKit
import ParticlesKit
import PlatformParticles
import Utilities

open class MapAnnotationObjectPresenterView: MKAnnotationView, ObjectPresenterProtocol, MapScalingObserverProtocol {
    public var scaling: MapScaling? {
        didSet {
            ((presenterView as? ObjectPresenterView)?.presenter as? MapScalingObserverProtocol)?.scaling = scaling
        }
    }

    public var model: ModelObjectProtocol? {
        get { return annotation as? (ModelObjectProtocol) }
        set { annotation = newValue as? MKAnnotation }
    }

    @IBOutlet public var presenterView: UIView? {
        didSet {
            changeObservation(from: oldValue, to: presenterView, keyPath: #keyPath(ObjectPresenterView.presenter)) { [weak self] _, _, _ in
                if let self = self {
                    ((self.presenterView as? ObjectPresenterView)?.presenter as? MapScalingObserverProtocol)?.scaling = self.scaling
                }
            }
        }
    }

    public var xib: String? {
        didSet {
            if xib != oldValue {
                presenterView?.removeFromSuperview()
                presenterView = installView(xib: xib)
                (presenterView as? ObjectPresenterView)?.model = model
                if let presenterView = presenterView {
                    centerOffset = CGPoint(x: 0, y: -presenterView.frame.size.height / 2)
                } else {
                    centerOffset = CGPoint(x: 0, y: 0)
                }
            }
        }
    }

    @objc open var selectable: Bool {
        return (presenterView as? ObjectPresenterView)?.selectable ?? false
    }

    override open var annotation: MKAnnotation? {
        didSet {
            if annotation !== oldValue {
//                layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
                present(model: model)
            }
        }
    }

    override public init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clipsToBounds = false
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: { [weak self] in
            if let self = self {
                (self.presenterView as? SelectableProtocol)?.isSelected = self.isSelected
                self.layer.opacity = 1
                self.transform = self.transform()
            }
        })
    }

    open func transform() -> CGAffineTransform {
        let scale: CGFloat = isSelected ? 1.1 : 1.0
        return CGAffineTransform.identity.scaledBy(x: scale, y: scale)
    }

    private func present(model: ModelObjectProtocol?) {
        (presenterView as? ObjectPresenterView)?.model = model
        if let draggable = model as? DraggableAnnotationProtocol {
            isDraggable = draggable.draggable
        } else {
            isDraggable = false
        }
    }
}

extension MapAnnotationObjectPresenterView {
    override open func setDragState(_ newDragState: MKAnnotationView.DragState, animated: Bool) {
        super.setDragState(newDragState, animated: animated)

        switch newDragState {
        case .starting:
            Console.shared.log("Starting \(newDragState)")
            startDragging()
        case .dragging:
            Console.shared.log("Dragging  \(newDragState)")
        case .ending, .canceling:
            Console.shared.log("Ending  \(newDragState)")
            endDragging()
        case .none:
            break
        @unknown default:
            fatalError("Unknown drag state")
        }
    }

    // When the user interacts with an annotation, animate opacity and scale changes.
    func startDragging() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.layer.opacity = 0.8
            self.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
        }, completion: nil)

        // Initialize haptic feedback generator and give the user a light thud.
        if #available(iOS 10.0, *) {
            let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
            hapticFeedback.impactOccurred()
        }
    }

    func endDragging() {
        transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.layer.opacity = 1
            self.transform = self.transform()
        }, completion: nil)

        // Give the user more haptic feedback when they drop the annotation.
        if #available(iOS 10.0, *) {
            let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
            hapticFeedback.impactOccurred()
        }
//        if let latitude = self.annotation?.coordinate.latitude, let longitude = self.annotation?.coordinate.longitude {
//            (model as? DraggableAnnotationProtocol)?.set(latitude: latitude, longitude: longitude)
//        }
    }

    open func scale() {
    }
}
