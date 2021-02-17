//
//  Colors.swift
//  Blockchain
//
//  Created by Maurice A. on 7/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// TODO: Colors should be declared in PlatformUIKit.UIColor+Application.swift
@objc
extension UIColor {

    // MARK: - Brand-specific Colors

    static let brandPrimary = #colorLiteral(red: 0, green: 0.2901960784, blue: 0.4862745098, alpha: 1)

    static let brandTertiary = #colorLiteral(red: 0.6980392157, green: 0.8352941176, blue: 0.8980392157, alpha: 1)

    static let brandYellow = #colorLiteral(red: 1, green: 0.8117647059, blue: 0.3843137255, alpha: 1)

    static let gray1 = #colorLiteral(red: 0.9176470588, green: 0.9176470588, blue: 0.9176470588, alpha: 1)

    static let darkGray = #colorLiteral(red: 0.26, green: 0.26, blue: 0.26, alpha: 1)
    
    static let gray6 = #colorLiteral(red: 0.2196078431, green: 0.2196078431, blue: 0.2196078431, alpha: 1)

    static let green = #colorLiteral(red: 0, green: 0.6549019608, blue: 0.4352941176, alpha: 1)

    static let red = #colorLiteral(red: 0.9490196078, green: 0.4235294118, blue: 0.3411764706, alpha: 1)

    // MARK: - App-specific Colors

    static let grayLine = #colorLiteral(red: 0.8039215686, green: 0.8039215686, blue: 0.8039215686, alpha: 1)

    static let keyPadButton = #colorLiteral(red: 0.831372549, green: 0.8509803922, blue: 0.8666666667, alpha: 1)

    static let lightGray = #colorLiteral(red: 0.9607843137, green: 0.9647058824, blue: 0.9725490196, alpha: 1)

    static let navigationBarBackground = UIColor.NavigationBar.LightContent.background
}
