// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import NetworkKit
@testable import OpenBankingUI
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
        XCTAssertNil(state.account)
        XCTAssertNil(state.selection)
        XCTAssertNil(state.route)
    }

    func test_route() throws {

        store.assert(
            .send(.navigate(to: .approve)) { state in
                state.route = .init(route: .approve, action: .navigateTo)
            }
        )

        store.assert(
            .send(.enter(into: .approve)) { state in
                state.route = .init(route: .approve, action: .enterInto(fullScreen: false))
            }
        )
    }

    func test_fetch() throws {

        store.assert(
            .send(.fetch),
            .do { [self] in scheduler.main.run() },
            .receive(.fetched(createAccount)) { [self] state in
                state.account = .success(createAccount)
            }
        )
    }

    func test_show_transfer_details() throws {
        store.assert(.send(.showTransferDetails))
        XCTAssertTrue(showTransferDetails)
    }

    func test_dismiss() throws {
        store.assert(.send(.dismiss))
        XCTAssertTrue(dismiss)
    }

    var approve: [Store.Step] {
        [
            .send(.fetched(createAccount)) { [self] state in
                state.account = .success(createAccount)
            },
            .send(.select(institution)) { [self] state in
                state.selection = .init(
                    bank: .init(account: createAccount, action: .link(institution: institution))
                )
            },
            .receive(.navigate(to: .approve)) { state in
                state.route = .init(route: .approve, action: .navigateTo)
            }
        ]
    }

    func test_select() throws {
        store.assert(approve)
    }

    func test_select_invalid() throws {
        store.assert(
            .send(.select(institution)),
            .receive(.fail(.message(R.InstitutionList.Error.invalidAccount))) { state in
                state.account = .failure(.message(R.InstitutionList.Error.invalidAccount))
            }
        )
    }

    func test_approve_deny() throws {
        store.assert(
            approve,
            .send(.approve(.deny)) { state in
                state.route = nil
            }
        )
    }

    func test_approve_bank_cancel() throws {
        store.assert(
            approve,
            .do { [self] in scheduler.main.advance() },
            .send(.approve(.bank(.cancel))) { state in
                state.route = nil
                state.account = nil
            },
            .receive(.fetch),
            .do { [self] in scheduler.main.advance() },
            .receive(.fetched(createAccount)) { [self] state in
                state.account = .success(createAccount)
            }
        )
    }
}
