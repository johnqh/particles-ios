//
//  CameraParticles.h
//  CameraParticles
//
//  Created by Qiang Huang on 7/11/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import AVFoundation
import Foundation

@objc open class VideoProcessingCapture: CameraCapture {
    @objc open dynamic var videoProcessing: AVCaptureVideoDataOutputSampleBufferDelegate? {
        didSet {
            if videoProcessing !== oldValue {
                setupProcessing()
            }
        }
    }

    open override func setupOutput() {
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        output.alwaysDiscardsLateVideoFrames = true
        self.output = output

        setupProcessing()
    }

    open func setupProcessing() {
        if let videoOutput = output as? AVCaptureVideoDataOutput {
            if let videoProcessing = videoProcessing {
                let queue = DispatchQueue(label: "video.processing")
                videoOutput.setSampleBufferDelegate(videoProcessing, queue: queue)
            } else {
                videoOutput.setSampleBufferDelegate(nil, queue: nil)
            }
        }
    }
}
