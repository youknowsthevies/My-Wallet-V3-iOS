// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

// TODO: Colors should be declared in PlatformUIKit.UIColor+Application.swift
@objc
extension UIColor {

    // MARK: - Brand-specific Colors

    static let brandPrimary = #colorLiteral(red: 0, green: 0.2901960784, blue: 0.4862745098, alpha: 1)

    static let darkGray = #colorLiteral(red: 0.26, green: 0.26, blue: 0.26, alpha: 1)

    static let green = #colorLiteral(red: 0, green: 0.6549019608, blue: 0.4352941176, alpha: 1)

    static let red = #colorLiteral(red: 0.9490196078, green: 0.4235294118, blue: 0.3411764706, alpha: 1)

    // MARK: - App-specific Colors

    static let lightGray = #colorLiteral(red: 0.9607843137, green: 0.9647058824, blue: 0.9725490196, alpha: 1)

    static let navigationBarBackground = UIColor.NavigationBar.LightContent.background
}
