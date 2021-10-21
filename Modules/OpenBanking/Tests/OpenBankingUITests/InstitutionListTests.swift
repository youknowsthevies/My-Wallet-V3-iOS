// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
@testable import OpenBankingUI
import NetworkKit
import TestKit

final class InstitutionListTests: XCTestCase {

    typealias Store = TestStore<
        InstitutionListState,
        InstitutionListState,
        InstitutionListAction,
        InstitutionListAction,
        OpenBankingEnvironment
    >

    private var store: Store!

    private var scheduler = (
        main: DispatchQueue.test,
        background: DispatchQueue.test
    )

    private var network: ReplayNetworkCommunicator!

    // swiftlint:disable:next force_try
    lazy var account = try! network[URLRequest(.post, "https://api.blockchain.info/nabu-gateway/payments/banktransfer")]
        .unwrap()
        .decode(to: OpenBanking.BankAccount.self)

    lazy var institution = account.attributes.institutions![1]

    override func setUpWithError() throws {
        try super.setUpWithError()
        scheduler = (main: DispatchQueue.test, background: DispatchQueue.test)
        let (environment, network) = OpenBankingEnvironment.test(
            scheduler: .init(
                main: scheduler.main.eraseToAnyScheduler(),
                background: scheduler.background.eraseToAnyScheduler()
            )
        )
        store = .init(
            initialState: .init(),
            reducer: institutionListReducer,
            environment: environment
        )
        self.network = network
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
            .receive(.fetched(account)) { state in
                state.account = .success(self.account)
            }
        )
    }

    func test_show_transfer_details() throws {

        let (environment, _) = OpenBankingEnvironment.test(
            showTransferDetails: expectation(description: "showTransferDetails").fulfill
        )

        store = .init(
            initialState: .init(),
            reducer: institutionListReducer,
            environment: environment
        )

        store.assert(.send(.showTransferDetails))
        waitForExpectations(timeout: 0)
    }

    func test_dismiss() throws {

        let (environment, _) = OpenBankingEnvironment.test(
            dismiss: expectation(description: "dismiss").fulfill
        )

        store = .init(
            initialState: .init(),
            reducer: institutionListReducer,
            environment: environment
        )

        store.assert(.send(.dismiss))
        waitForExpectations(timeout: 0)
    }

    var approve: [Store.Step] {
        [
            .send(.fetched(account)) { [self] state in
                state.account = .success(account)
            },
            .send(.select(institution)) { [self] state in
                state.selection = .init(
                    bank: .init(account: account, action: .link(institution: institution))
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
            .receive(.fetched(account)) { [self] state in
                state.account = .success(account)
            }
        )
    }
}

extension TestStore where LocalState: Equatable, Action: Equatable {

    /// Asserts against a script of actions.
    public func assert(
        _ first: [Step],
        _ rest: Step...,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        assert(first + rest, file: file, line: line)
    }
}
