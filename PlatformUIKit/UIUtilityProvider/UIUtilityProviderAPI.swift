//
//  UIUtilityProviderAPI.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 05/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public protocol UIUtilityProviderAPI: AnyObject {
    var alert: AlertViewPresenterAPI { get }
    var loader: LoadingViewPresenting { get }
}
