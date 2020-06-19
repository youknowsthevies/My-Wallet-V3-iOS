//
//  RouterAPI.swift
//  BuySellUIKit
//
//  Created by Daniel Huri on 04/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public protocol RouterAPI: class {
    func start()
    func next(to state: StateService.State)
    func previous(from state: StateService.State)
    func showCryptoSelectionScreen()
}
