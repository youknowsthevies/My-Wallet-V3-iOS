//
//  UIView+SafeAreaFrame.swift
//  Blockchain
//
//  Created by Maurice A. on 6/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc
extension UIView {
    /**
     UIView Safe Area Frame Extension
     - Note: must only be called when safe area insets have been set (viewSafeAreaInsetsDidChange(), viewDidLayoutSubviews())
     - Note: this extension only supports the default screen orientation.
     - Parameter navigationBar: the height of the navigation bar should be considered when sizing the frame.
     - Parameter tabBar: the height of the tab bar should be considered when sizing the frame.
     - Parameter: assetSelector: the height of the asset selector should be considered when sizing the frame.
     */
    class func rootViewSafeAreaFrame(
        navigationBar: Bool = false,
        tabBar: Bool = false,
        assetSelector: Bool = false
        ) -> CGRect {
        guard let viewController = rootViewController() else {
            return CGRect.zero
        }

        var additionalSpace: CGFloat = 0
        if navigationBar {
            additionalSpace += Constants.Measurements.DefaultNavigationBarHeight
        }

        if tabBar {
            additionalSpace += Constants.Measurements.DefaultTabBarHeight
        }

        if assetSelector {
            additionalSpace += Constants.Measurements.AssetSelectorHeight
        }

        let safeAreaLayoutFrame = viewController.view.safeAreaLayoutGuide.layoutFrame
        let height = safeAreaLayoutFrame.size.height - additionalSpace
        let frame = CGRect(x: 0, y: 0, width: safeAreaLayoutFrame.size.width, height: height)
        return frame
    }

    class func rootViewSafeAreaInsets() -> UIEdgeInsets {
        rootViewController()?.view.safeAreaInsets ?? .zero
    }

    private class func rootViewController() -> UIViewController? {
        UIApplication.shared.keyWindow?.rootViewController
    }
}
