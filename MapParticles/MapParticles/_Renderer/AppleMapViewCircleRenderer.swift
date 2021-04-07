//
//  AppleMapViewCircleRenderer.swift
//  MapParticles
//
//  Created by Qiang Huang on 1/31/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import MapKit
import UIKit

public class AppleMapViewCircleRenderer: MKCircleRenderer {
    public var textColor: UIColor?

    public override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        super.draw(mapRect, zoomScale: zoomScale, in: context)

        if let circle = self.overlay as? ColoredCircle, let text = circle.text {
            let kScreenScale: CGFloat = UIScreen.main.scale
            let kScreenFraction: CGFloat = 0.5
            let kFontSize: CGFloat = 9.0 * kScreenScale
            UIGraphicsPushContext(context)
            context.saveGState()

            let nsText = text as NSString

            let scaledFont = UIFont.systemFont(ofSize: kFontSize / zoomScale, weight: .regular)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
            paragraphStyle.alignment = NSTextAlignment.center

            let fontAttributes = [NSAttributedString.Key.font: scaledFont, NSAttributedString.Key.foregroundColor: textColor ?? UIColor.black, NSAttributedString.Key.paragraphStyle: paragraphStyle]

            let screenSize = UIScreen.main.bounds.size
            let halfSize = CGSize(width: screenSize.width / zoomScale * kScreenFraction * kScreenScale, height: screenSize.height / zoomScale * kScreenScale)

            let textSize = nsText.boundingRect(with: halfSize, options: .usesLineFragmentOrigin, attributes: fontAttributes, context: nil).size

            let rect: CGRect = self.rect(for: circle.boundingMapRect)
            let bottom = rect.origin.y + rect.size.height
            let center = rect.origin.x + rect.size.width / 2.0
            let drawPoint = CGPoint(x: center - textSize.width / 2.0, y: bottom + 4 * kScreenScale / zoomScale)

            nsText.draw(with: CGRect(origin: drawPoint, size: textSize), options: .usesLineFragmentOrigin, attributes: fontAttributes, context: nil)

            context.restoreGState()
            UIGraphicsPopContext()
        }
    }
}
