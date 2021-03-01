//
//  TargetSelectionPageState.swift
//  TransactionUIKit
//
//  Created by Alex McGregor on 2/24/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

enum TargetSelectionPageStep {
    // TODO: QR Scanning Step
    case initial
    case complete
    case closed
    
    var addToBackStack: Bool {
        switch self {
        case .closed,
             .complete,
             .initial:
            return false
        }
    }
}

struct TargetSelectionPageState: Equatable, StateType {
    
    static let empty = TargetSelectionPageState()
    
    var nextEnabled: Bool = false
    var isGoingBack: Bool = false
    var sourceAccount: BlockchainAccount?
    var availableTargets: [BlockchainAccount]?
    var destination: BlockchainAccount?
    var stepsBackStack: [TargetSelectionPageStep] = []
    var step: TargetSelectionPageStep = .initial {
        didSet {
            isGoingBack = false
        }
    }
    // TODO: Handle alternate destination type
    // of an address
    
    static func == (lhs: TargetSelectionPageState, rhs: TargetSelectionPageState) -> Bool {
        lhs.nextEnabled == rhs.nextEnabled &&
        lhs.destination?.label == rhs.destination?.label &&
        lhs.sourceAccount?.label == rhs.sourceAccount?.label &&
        lhs.step == rhs.step &&
        lhs.stepsBackStack == rhs.stepsBackStack
    }
}

extension TargetSelectionPageState {
    func withUpdatedBackstack(oldState: TargetSelectionPageState) -> TargetSelectionPageState {
        if oldState.step != step, oldState.step.addToBackStack {
            var newState = self
            var newStack = oldState.stepsBackStack
            newStack.append(oldState.step)
            newState.stepsBackStack = newStack
            return newState
        }
        return self
    }
}
