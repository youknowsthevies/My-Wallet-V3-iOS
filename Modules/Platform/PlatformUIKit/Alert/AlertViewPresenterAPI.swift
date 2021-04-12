//
//  AlertViewPresenterAPI.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 05/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public protocol AlertViewPresenterAPI: AnyObject {
    func notify(content: AlertViewContent, in viewController: UIViewController?)
    func error(in viewController: UIViewController?, action: (() -> Void)?)
}
