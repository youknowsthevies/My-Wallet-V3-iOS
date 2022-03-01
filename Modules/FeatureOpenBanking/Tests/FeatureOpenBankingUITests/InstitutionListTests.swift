// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
@testable import FeatureOpenBankingUI
import NetworkKit
import TestKit

final class InstitutionListTests: OpenBankingTestCase {

    typealias Store = TestStore<
        InstitutionListState,
        InstitutionListState,
        InstitutionListAction,
        InstitutionListAction,
        OpenBankingEnvironment
    >

    private var store: Store!

    override func setUpWithError() throws {
        try super.setUpWithError()
        store = .init(
            initialState: .init(),
            reducer: institutionListReducer,
            environment: environment
        )
    }

    func test_initial_state() throws {
        let state = InstitutionListState()
        XCTAssertNil(state.result)
        XCTAssertNil(state.selection)
        XCTAssertNil(state.route)
    }

    func test_route() throws {

        store.send(.navigate(to: .approve)) { state in
            state.route = .init(route: .approve, action: .navigateTo)
        }

        store.send(.enter(into: .approve)) { state in
            state.route = .init(route: .approve, action: .enterInto(.default))
        }
    }

    func test_fetch() throws {
        store.send(.fetch)
        scheduler.run()
        store.receive(.fetched(createAccount)) { [self] state in
            state.result = .success(createAccount)
        }
    }

    func test_show_transfer_details() throws {
        store.send(.showTransferDetails)
        XCTAssertTrue(showTransferDetails)
    }

    func test_dismiss() throws {
        store.send(.dismiss)
        XCTAssertTrue(dismiss)
    }

    func approve() {
        store.send(.fetched(createAccount)) { [self] state in
            state.result = .success(createAccount)
        }
        store.send(.select(createAccount, institution)) { [self] state in
            state.selection = .init(
                bank: .init(data: .init(
                    account: createAccount,
                    action: .link(
                        institution: institution
                    )
                ))
            )
        }
        store.receive(.navigate(to: .approve)) { state in
            state.route = .init(route: .approve, action: .navigateTo)
        }
    }

    func test_select_institution() throws {
        approve()
    }

    func test_approve_deny() throws {
        store.send(.approve(.deny))
    }

    func test_approve_bank_cancel() throws {
        approve()

        scheduler.advance()

        store.send(.approve(.bank(.cancel))) { state in
            state.route = nil
            state.result = nil
        }
        store.receive(.fetch)

        scheduler.advance()

        store.receive(.fetched(createAccount)) { [self] state in
            state.result = .success(createAccount)
        }
    }
}
