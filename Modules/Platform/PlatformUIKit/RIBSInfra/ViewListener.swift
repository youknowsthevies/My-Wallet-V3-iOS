// Copyright © Blockchain Luxembourg S.A. All rights reserved.

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
