//
//  TargetSelectionAction.swift
//  TransactionUIKit
//
//  Created by Alex McGregor on 2/24/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

enum TargetSelectionAction: MviAction {
    
    case sourceAccountSelected(BlockchainAccount, AssetAction)
    case availableTargets([BlockchainAccount])
    case validateAddress(String, CryptoAccount)
    case destinationSelected(BlockchainAccount)
    case destinationConfirmed
    case returnToPreviousStep
    case resetFlow
    
    func reduce(oldState: TargetSelectionPageState) -> TargetSelectionPageState {
        switch self {
        case .availableTargets(let accounts):
            return oldState
                .update(keyPath: \.availableTargets, value: accounts)
        case .sourceAccountSelected(let account, _):
            return oldState
                .update(keyPath: \.sourceAccount, value: account)
        case .destinationSelected(let account):
            return oldState
                .update(keyPath: \.destination, value: account)
                .update(keyPath: \.nextEnabled, value: true)
        case .destinationConfirmed:
            return oldState.update(keyPath: \.step, value: .complete)
        case .validateAddress:
            return oldState
        case .returnToPreviousStep:
            var stepsBackStack = oldState.stepsBackStack
            let previousStep = stepsBackStack.popLast() ?? .initial
            return oldState
                .update(keyPath: \.stepsBackStack, value: stepsBackStack)
                .update(keyPath: \.step, value: previousStep)
                .update(keyPath: \.isGoingBack, value: true)
        case .resetFlow:
            return oldState
                .update(keyPath: \.step, value: .closed)
        }
    }
}
