// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Combine
import ComposableArchitecture
import FeatureCoinDomain
import Localization
import SwiftUI
import ToolKit

public let coinViewReducer = Reducer<
    CoinViewState,
    CoinViewAction,
    CoinViewEnvironment
>.combine(
    graphViewReducer
        .pullback(
            state: \.graph,
            action: /CoinViewAction.graph,
            environment: { $0 }
        ),
    .init { state, action, environment in
        switch action {

        case .loadKycStatus:
            return environment.kycStatusProvider()
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .map { kycStatus in
                    .updateKycStatus(kycStatus)
                }

        case .updateKycStatus(kycStatus: let kycStatus):
            state.kycStatus = kycStatus
            return .none

        case .loadAccounts:
            return environment.accountsProvider()
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .map { assetDetails in
                    .updateAccounts(assetDetails)
                }

        case .updateAccounts(accounts: let accounts):
            state.accounts = accounts
            return state.accounts.hasPositiveBalanceForSelling
                .eraseToEffect()
                .map {
                    .updateHasPositiveBalanceForSelling($0)
                }

        case .updateHasPositiveBalanceForSelling(let hasPositiveBalanceForSelling):
            state.hasPositiveBalanceForSelling = hasPositiveBalanceForSelling
            return .none

        case .graph:
            return .none
        }
    }
)
