//
//  ActivityScreenViewControllerProvider.swift
//  Blockchain
//
//  Created by Dimitrios Chatzieleftheriou on 23/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import ActivityUIKit

// MARK: Objective-C compatibility

extension ActivityScreenViewController {
    @objc public class func provideController() -> ActivityScreenViewController {
        ActivityScreenViewController()
    }
}
