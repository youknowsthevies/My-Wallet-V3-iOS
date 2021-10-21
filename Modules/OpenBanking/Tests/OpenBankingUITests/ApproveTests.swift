// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
@testable import OpenBankingUI
import NetworkKit
import TestKit

final class ApproveTests: XCTestCase {

    typealias Store = TestStore<
        ApproveState,
        ApproveState,
        ApproveAction,
        ApproveAction,
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
        self.network = network
        store = .init(
            initialState: .init(bank: .init(account: account, action: .link(institution: institution))),
            reducer: approveReducer,
            environment: environment
        )
    }

    func test_initial_state() throws {

    }

}
