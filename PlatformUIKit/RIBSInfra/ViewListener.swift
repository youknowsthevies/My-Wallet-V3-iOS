//
//  ViewListener.swift
//  PlatformUIKit
//
//  Created by Paulo on 12/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol ViewListener: AnyObject {
    func viewDidLoad()
    func viewWillAppear()
    func viewDidAppear()
    func viewDidDisappear()
}

public extension ViewListener {
    func viewDidLoad() { }
    func viewWillAppear() { }
    func viewDidAppear() { }
    func viewDidDisappear() { }
}
