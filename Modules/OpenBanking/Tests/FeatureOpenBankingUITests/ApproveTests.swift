// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import NetworkKit
@testable import FeatureOpenBankingUI
import TestKit

final class ApproveTests: OpenBankingTestCase {

    typealias Store = TestStore<
        ApproveState,
        ApproveState,
        ApproveAction,
        ApproveAction,
        OpenBankingEnvironment
    >

    private var store: Store!

    override func setUpWithError() throws {
        try super.setUpWithError()
        store = .init(
            initialState: initialState,
            reducer: approveReducer,
            environment: environment
        )
    }

    var initialState: ApproveState {
        ApproveState(
            bank: .init(data: .init(account: createAccount, action: .link(institution: institution)))
        )
    }

    func test_initial_state() throws {
        let state = initialState
        XCTAssertNil(state.route)
        XCTAssertNil(state.ui)
    }

    func test_onAppear() throws {
        store.assert(
            .send(.onAppear) { [self] state in
                state.ui = .model(for: .init(account: createAccount, action: .link(institution: institution)), in: environment)
            }
        )
    }

    func test_onAppear_pay() throws {

        store = .init(
            initialState: ApproveState(
                bank: .init(data: .init(account: createAccount, action: .deposit(amountMinor: "1000", product: "SIMPLEBUY")))
            ),
            reducer: approveReducer,
            environment: environment
        )

        store.assert(
            .send(.onAppear) { [self] state in
                state.ui = .model(for: .init(account: createAccount, action: .deposit(amountMinor: "1000", product: "SIMPLEBUY")), in: environment)
            }
        )
    }

    func test_approve() throws {
        store.assert(
            .send(.approve),
            .receive(.navigate(to: .bank)) { state in
                state.route = .init(route: .bank, action: .navigateTo)
            }
        )
    }

    func test_dismiss() throws {
        store.assert(.send(.dismiss))
        XCTAssertTrue(dismiss)
    }

    func test_deny() throws {
        store.assert(.send(.deny))
    }
}
