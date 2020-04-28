//
//  PendingStatePresenterAPI.swift
//  Blockchain
//
//  Created by Daniel Huri on 21/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa

public protocol PendingStatePresenterAPI: class {
    var title: String { get }
    var viewModel: Driver<PendingStateViewModel> { get }
    
    func viewDidLoad()
}

extension PendingStatePresenterAPI {
    public var title: String {
        return ""
    }
    public func viewDidLoad() {}
}
