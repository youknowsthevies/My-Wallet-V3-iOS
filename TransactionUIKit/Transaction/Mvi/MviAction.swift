//
//  MviAction.swift
//  TransactionUIKit
//
//  Created by Paulo on 03/11/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol MviAction {
    associatedtype State

    func reduce(oldState: State) -> State
    func isValid(for oldState: State) -> Bool
}

extension MviAction {
    func isValid(for oldState: State) -> Bool { true }
}
