//
//  CameraParticles.h
//  CameraParticles
//
//  Created by Qiang Huang on 7/11/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import AVFoundation
import Foundation

@objc public enum EScanningStatus: Int {
    case idle
    case scanning
    case processing
}

@objc open class VideoProcessingViewController: CameraViewController {
    open var scanningStatus: EScanningStatus = .idle {
        didSet {
            if scanningStatus != oldValue {
                updateTo(scanningStatus: scanningStatus)
            }
        }
    }

    public var videoCapture: VideoProcessingCapture? {
        return capture as? VideoProcessingCapture
    }

    open var videoProcessor: VideoScanner? {
        didSet {
            if videoProcessor !== oldValue {
                videoCapture?.videoProcessing = videoProcessor
                videoProcessor?.scanning = (scanningStatus == .scanning)
            }
        }
    }

    override open func createCapture() -> CameraCapture? {
        return VideoProcessingCapture()
    }

    open func updateTo(scanningStatus: EScanningStatus) {
        videoProcessor?.scanning = (scanningStatus == .scanning)
    }
}
