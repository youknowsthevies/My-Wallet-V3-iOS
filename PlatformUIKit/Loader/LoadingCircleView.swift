//
//  LoadingCircleView.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 11/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public class LoadingCircleView: UIView {

    // MARK: - Properties

    /// The width of the stroke line
    let strokeWidth: CGFloat = 8

    override public var layer: CAShapeLayer {
        return super.layer as! CAShapeLayer
    }

    override public class var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    // MARK: - Setup

    init(diameter: CGFloat, strokeColor: UIColor, strokeBackgroundColor: UIColor, fillColor: UIColor) {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: diameter, height: diameter)))
        configure(layer, strokeColor: strokeColor, fillColor: fillColor)
        let strokeBackgroundLayer: CAShapeLayer = CAShapeLayer()
        configure(strokeBackgroundLayer, strokeColor: strokeBackgroundColor, fillColor: fillColor)
        layer.addSublayer(strokeBackgroundLayer)
        isAccessibilityElement = false
    }

    private func configure(_ layer: CAShapeLayer, strokeColor: UIColor, fillColor: UIColor) {
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = strokeWidth
        layer.lineCap = .round
        layer.fillColor = fillColor.cgColor
        layer.path = UIBezierPath(ovalIn: bounds.insetBy(dx: strokeWidth / 2, dy: strokeWidth / 2)).cgPath
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
