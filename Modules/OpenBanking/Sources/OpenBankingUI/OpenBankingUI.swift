// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableNavigation
@_exported import OpenBanking
import SwiftUI

public enum OpenBankingState: Equatable {
    case institutionList(InstitutionListState)
    case approve(ApproveState)
}

extension OpenBankingState {

    public static var linkBankAccount: Self {
        .institutionList(.init())
    }

    public static func pay(amountMinor: String, product: String, from bankAccount: OpenBanking.BankAccount) -> Self {
        .approve(
            .init(
                bank: .init(
                    account: bankAccount,
                    action: .pay(amountMinor: amountMinor, product: product)
                )
            )
        )
    }
}

public enum OpenBankingAction {
    case institutionList(InstitutionListAction)
    case approve(ApproveAction)
}

public let openBankingReducer = Reducer<OpenBankingState, OpenBankingAction, OpenBankingEnvironment>
    .combine(
        institutionListReducer
            .pullback(
                state: /OpenBankingState.institutionList,
                action: /OpenBankingAction.institutionList,
                environment: \.environment
            ),
        approveReducer
            .pullback(
                state: /OpenBankingState.approve,
                action: /OpenBankingAction.approve,
                environment: \.environment
            ),
        .init { _, action, environment in
            switch action {
            case .approve(.bank(.fail(let error))),
                 .institutionList(.approve(.bank(.fail(let error)))):
                environment.event$.send(.failed(error))
                return .none
            case .institutionList(.approve(.bank(.linked(let account)))):
                environment.event$.send(.linked(account))
                return .none
            case .approve(.bank(.authorised(let account, let payment))):
                environment.event$.send(.authorised(account, payment: payment))
                return .none
            case .approve:
                return .none
            case .institutionList:
                return .none
            }
        }
    )
    .debug()

public struct OpenBankingView: View {

    let store: Store<OpenBankingState, OpenBankingAction>
    let environment: OpenBankingEnvironment

    public init(state: OpenBankingState, environment: OpenBankingEnvironment) {
        self.init(
            store: .init(
                initialState: state,
                reducer: openBankingReducer,
                environment: environment
            ),
            in: environment
        )
    }

    private init(store: Store<OpenBankingState, OpenBankingAction>, in environment: OpenBankingEnvironment) {
        self.store = store
        self.environment = environment
    }

    public var body: some View {
        SwitchStore(store) {
            CaseLet(
                state: /OpenBankingState.institutionList,
                action: OpenBankingAction.institutionList,
                then: InstitutionList.init(store:)
            )
            CaseLet(
                state: /OpenBankingState.approve,
                action: OpenBankingAction.approve,
                then: ApproveView.init(store:)
            )
        }
    }
}
