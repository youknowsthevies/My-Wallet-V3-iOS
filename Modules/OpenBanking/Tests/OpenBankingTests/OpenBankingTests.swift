// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CombineSchedulers
@testable import NetworkKit
@testable import OpenBanking
import TestKit

// swiftlint:disable line_length
// swiftlint:disable single_test_class

final class OpenBankingTests: XCTestCase {

    var banking: OpenBanking!
    var network: ReplayNetworkCommunicator!

    override func setUpWithError() throws {
        try super.setUpWithError()
        (banking, network) = OpenBanking.test()
    }

    func test_create_bank_account_set_state_id() throws {
        _ = try banking.createBankAccount().wait()
        try XCTAssertEqual(banking.state.get(.id), Identity<OpenBanking.BankAccount>("a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c"))
    }

    func test_handle_consent_token_without_callback_path() throws {
        banking.state.set(.consent.token, to: "token")
        let error: OpenBanking.State.Error = try banking.state.get(.consent.error)
        XCTAssertEqual(error, .keyDoesNotExist(.callback.path))
    }

    func test_handle_consent_token_error() throws {

        network.error(
            URLRequest(
                url: "https://api.blockchain.info/nabu-gateway/payments/banktransfer/one-time-token",
                method: .post
            ).json()
        )

        banking.state.transaction { state in
            state.set(.callback.path, to: "/payments/banktransfer/one-time-token")
            state.set(.consent.token, to: "token")
        }

        XCTAssertTrue(banking.state.contains(.consent.error))
        try XCTAssertFalse(banking.state.get(.is.authorised))
    }

    func test_handle_consent_token() throws {

        banking.state.set(.callback.path, to: "/payments/banktransfer/one-time-token")
        banking.state.set(.consent.token, to: "token")

        let request = try network.requests[
            .post, "https://api.blockchain.info/nabu-gateway/payments/banktransfer/one-time-token"
        ].unwrap()

        try XCTAssertEqual(request.body, ["oneTimeToken": "token"].data())

        try XCTAssertTrue(banking.state.get(.is.authorised))
        XCTAssertFalse(banking.state.contains(.consent.error))
    }

    func test_get_all() throws {
        _ = try banking.allBankAccounts().wait().get()
        let request = try network.requests[.get, "https://api.blockchain.info/nabu-gateway/payments/banktransfer"].unwrap()
        XCTAssertTrue(request.authenticated)
    }
}

final class OpenBankingBankAccountTests: XCTestCase {

    var banking: OpenBanking!
    var network: ReplayNetworkCommunicator!
    var bankAccount: OpenBanking.BankAccount!
    var institution: OpenBanking.Institution!

    override func setUpWithError() throws {
        try super.setUpWithError()
        (banking, network) = OpenBanking.test()
        bankAccount = try banking.createBankAccount().wait()
        institution = bankAccount.attributes.institutions?[1]
    }

    func test_activate_institution() throws {

        let account = try bankAccount.activateBankAccount(with: institution.id, in: banking).wait()

        XCTAssertEqual(account.state, "PENDING")

        let request = try network.requests[
            .post, "https://api.blockchain.info/nabu-gateway/payments/banktransfer/a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c/update"
        ].unwrap()

        try XCTAssertEqual(
            request.body?.json() as? [String: [String: String]],
            [
                "attributes": [
                    "institutionId": "monzo_ob",
                    "callback": "https://blockchainwallet.page.link/oblinking"
                ]
            ]
        )
    }

    func test_get_sets_authorisation_state() throws {

        let account = try bankAccount.get(in: banking).wait()

        XCTAssertEqual(account.id, bankAccount.id)
        try XCTAssertEqual(account.attributes.authorisationUrl, banking.state.get(.authorisation.url))

        XCTAssertEqual(account.attributes.callbackPath, "nabu-gateway/payments/banktransfer/one-time-token")
        try XCTAssertEqual(banking.state.get(.callback.path), "/payments/banktransfer/one-time-token")
    }

    func test_activate_institution_clear_existing_state() throws {

        banking.state.set(.authorisation.url, to: "url")
        banking.state.set(.callback.path, to: "path")

        _ = try bankAccount.activateBankAccount(with: institution.id, in: banking).wait()

        XCTAssertThrowsError(try banking.state.get(.authorisation.url))
        XCTAssertThrowsError(try banking.state.get(.callback.path))
    }

    func test_delete() throws {

        XCTAssertNoThrow(try banking.state.get(.id))

        let promise = expectation(description: "sunk")
        let subscription = bankAccount.delete(in: banking)
            .sink(to: XCTestExpectation.fulfill, on: promise)

        wait(for: [promise], timeout: 1)

        XCTAssertThrowsError(try banking.state.get(.id))

        subscription.cancel()

        let request = try network.requests[
            .delete, "https://api.blockchain.info/nabu-gateway/payments/banktransfer/a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c"
        ].unwrap()

        XCTAssertTrue(request.authenticated)
    }

    func test_create_payment() throws {

        let payment = try bankAccount.pay(
            amountMinor: "1000",
            product: "SIMPLEBUY",
            in: banking
        )
        .wait()

        let request = network.requests[
            .post, "https://api.blockchain.info/nabu-gateway/payments/banktransfer/a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c/payment"
        ]

        try XCTAssertEqual(
            request?.body,
            [
                "currency": "GBP",
                "amountMinor": "1000",
                "product": "SIMPLEBUY",
                "attributes": [
                    "callback": "https://blockchainwallet.page.link/obapproval"
                ]
            ].json(options: .sortedKeys)
        )

        XCTAssertEqual(payment.id, "b039317d-df85-413f-932d-2719346a839a")

        try XCTAssertEqual(banking.state.get(.callback.path), "/payments/banktransfer/one-time-token")
        XCTAssertEqual(payment.attributes.callbackPath, "nabu-gateway/payments/banktransfer/one-time-token")
    }
}

final class OpenBankingBankAccountPollTests: XCTestCase {

    var banking: OpenBanking!
    var network: ReplayNetworkCommunicator!
    var bankAccount: OpenBanking.BankAccount!
    var institution: OpenBanking.Institution!
    var scheduler: TestSchedulerOf<DispatchQueue>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        scheduler = DispatchQueue.test
        (banking, network) = OpenBanking.test(using: scheduler)
        bankAccount = try banking.createBankAccount().wait()
        institution = bankAccount.attributes.institutions?[1]
    }

    func get() -> URLRequest {
        URLRequest(
            url: "https://api.blockchain.info/nabu-gateway/payments/banktransfer/a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c",
            method: .get
        ).json()
    }

    func test_poll_with_error() throws {

        network[get()] = try OpenBanking.BankAccount(
            id: "a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c",
            partner: "YAPILY",
            error: .BANK_TRANSFER_ACCOUNT_ALREADY_LINKED,
            attributes: .init(entity: "SafeConnect(UK)")
        )
        .data()

        let account = try bankAccount.poll(in: banking).wait().get()

        XCTAssertEqual(account.error, .BANK_TRANSFER_ACCOUNT_ALREADY_LINKED)
    }

    func test_poll_when_pending() throws {

        let request = get()

        network[request] = try OpenBanking.BankAccount(
            id: "a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c",
            partner: "YAPILY",
            state: .PENDING,
            attributes: .init(entity: "SafeConnect(UK)")
        )
        .data()

        var result: Result<OpenBanking.BankAccount, OpenBanking.Error>?
        let subscription = bankAccount.poll(in: banking)
            .sink { result = $0 }

        XCTAssertNil(result)

        for _ in 0..<60 {
            scheduler.advance(by: .seconds(2))
        }

        let account = try XCTUnwrap(result)
        XCTAssertThrowsError(try account.get())

        subscription.cancel()
    }

    func test_poll_when_pending_then_eventually_succeed() throws {

        let request = get()

        network[request] = try OpenBanking.BankAccount(
            id: "a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c",
            partner: "YAPILY",
            state: .PENDING,
            attributes: .init(entity: "SafeConnect(UK)")
        )
        .data()

        var result: Result<OpenBanking.BankAccount, OpenBanking.Error>?
        let subscription = bankAccount.poll(in: banking)
            .sink { result = $0 }

        for _ in 0..<10 {
            scheduler.advance(by: .seconds(2))
        }

        XCTAssertNil(result)

        for _ in 0..<10 {
            scheduler.advance(by: .seconds(2))
        }

        network[request] = try OpenBanking.BankAccount(
            id: "a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c",
            partner: "YAPILY",
            state: .ACTIVE,
            attributes: .init(entity: "SafeConnect(UK)")
        )
        .data()

        scheduler.advance(by: .seconds(2))

        let account = try XCTUnwrap(result).get()

        XCTAssertEqual(account.state, .ACTIVE)

        subscription.cancel()
    }

    func x_test_poll_realtime() throws {

        (banking, network) = OpenBanking.test(using: DispatchQueue.main)

        let request = get()

        network[request] = try OpenBanking.BankAccount(
            id: "a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c",
            partner: "YAPILY",
            state: "PENDING",
            attributes: .init(entity: "SafeConnect(UK)")
        )
        .data()

        let promise = expectation(description: "")
        let __ = expectation(description: ""); __.isInverted = true

        var result: Result<OpenBanking.BankAccount, OpenBanking.Error>?

        let subscription = bankAccount.poll(in: banking)
            .sink {
                result = $0; promise.fulfill()
            }

        wait(for: [__], timeout: 5)

        network[request] = try OpenBanking.BankAccount(
            id: "a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c",
            partner: "YAPILY",
            state: .ACTIVE,
            attributes: .init(entity: "SafeConnect(UK)")
        )
        .data()

        wait(for: [promise], timeout: 2)

        subscription.cancel()

        let account = try XCTUnwrap(result).get()

        XCTAssertEqual(account.state, .ACTIVE)
    }
}

final class OpenBankingPaymentTests: XCTestCase {

    var banking: OpenBanking!
    var network: ReplayNetworkCommunicator!
    var bankAccount: OpenBanking.BankAccount!
    var payment: OpenBanking.Payment!
    var scheduler: TestSchedulerOf<DispatchQueue>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        scheduler = DispatchQueue.test
        (banking, network) = OpenBanking.test(using: scheduler)
        bankAccount = try banking.allBankAccounts().wait().get().first.unwrap()
        payment = try bankAccount.pay(amountMinor: "1000", product: "SIMPLEBUY", in: banking).wait()
    }

    func test_get() throws {
        _ = try payment.get(in: banking).wait()
        XCTAssertNoThrow(try banking.state.get(.authorisation.url))
    }

    func get() -> URLRequest {
        URLRequest(
            url: "https://api.blockchain.info/nabu-gateway/payments/payment/b039317d-df85-413f-932d-2719346a839a",
            method: .get
        )
        .json()
    }

    func test_poll_error() throws {

        network[get()] = try OpenBanking.Payment.Details(
            id: "b039317d-df85-413f-932d-2719346a839a",
            amount: .init(symbol: "GBP", value: "1000"),
            extraAttributes: .init(error: "ERROR_CODE"),
            insertedAt: "DATE",
            state: .FAILED,
            type: "CHARGE",
            beneficiaryId: "..."
        )
        .data()

        let details = try payment.poll(in: banking).wait().get()
        XCTAssertEqual(details.extraAttributes?.error, "ERROR_CODE")
    }

    func test_poll_pending_timeout() throws {

        network[get()] = try OpenBanking.Payment.Details(
            id: "b039317d-df85-413f-932d-2719346a839a",
            amount: .init(symbol: "GBP", value: "1000"),
            insertedAt: "DATE",
            state: .PENDING,
            type: "CHARGE",
            beneficiaryId: "..."
        )
        .data()

        var result: Result<OpenBanking.Payment.Details, OpenBanking.Error>!
        let subscription = payment.poll(in: banking)
            .sink { result = $0 }

        scheduler.advance(by: .seconds(2))

        XCTAssertNil(result)

        for _ in 0..<62 {
            scheduler.advance(by: .seconds(2))
        }

        switch try result.unwrap() {
        case .failure(.timeout):
            break
        case let value:
            XCTFail("\(value)")
        }

        subscription.cancel()
    }

    func test_poll_when_pending_then_eventually_succeed() throws {

        network[get()] = try OpenBanking.Payment.Details(
            id: "b039317d-df85-413f-932d-2719346a839a",
            amount: .init(symbol: "GBP", value: "1000"),
            insertedAt: "DATE",
            state: .PENDING,
            type: "CHARGE",
            beneficiaryId: "..."
        )
        .data()

        var result: Result<OpenBanking.Payment.Details, OpenBanking.Error>?
        let subscription = payment.poll(in: banking)
            .sink { result = $0 }

        for _ in 0..<10 {
            scheduler.advance(by: .seconds(2))
        }

        network[get()] = try OpenBanking.Payment.Details(
            id: "b039317d-df85-413f-932d-2719346a839a",
            amount: .init(symbol: "GBP", value: "1000"),
            extraAttributes: .init(authorisationUrl: "https://monzo.com"),
            insertedAt: "DATE",
            state: .COMPLETE,
            type: "CHARGE",
            beneficiaryId: "..."
        )
        .data()

        scheduler.advance(by: .seconds(2))

        let account = try XCTUnwrap(result).get()

        XCTAssertEqual(account.state, .COMPLETE)

        subscription.cancel()
    }
}

extension Array where Element == NetworkRequest {

    subscript(method: NetworkRequest.NetworkMethod, url: URL) -> NetworkRequest? {
        first(where: { $0.method == method && $0.urlRequest.url == url })
    }
}

extension URLRequest {
    func json() -> Self {
        var request = self
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}
