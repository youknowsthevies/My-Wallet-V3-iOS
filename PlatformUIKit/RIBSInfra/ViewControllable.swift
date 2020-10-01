//
//  ViewControllable.swift
//  PlatformUIKit
//
//  Created by Daniel on 16/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//  Implementation Reference: https://github.com/uber/RIBs (RIBs Architecture by Uber)
//

/// Basic interface between a `Router` and the UIKit `UIViewController`.
public protocol ViewControllable: class {

    var uiViewController: UIViewController { get }
}

/// Default implementation on `UIViewController` to conform to `ViewControllable` protocol
public extension ViewControllable where Self: UIViewController {

    var uiViewController: UIViewController {
        self
    }
}
