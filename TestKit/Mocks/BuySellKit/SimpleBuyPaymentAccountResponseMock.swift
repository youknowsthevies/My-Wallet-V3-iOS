//
//  SimpleBuyPaymentAccountResponseMock.swift
//  PlatformKitTests
//
//  Created by Paulo on 05/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import PlatformKit
@testable import BuySellKit

extension SimpleBuyPaymentAccountResponse {
    static func mock(with currency: FiatCurrency, agent: SimpleBuyPaymentAccountResponse.Agent) -> SimpleBuyPaymentAccountResponse {
        return SimpleBuyPaymentAccountResponse(
            id: "response id",
            address: "response bank account",
            agent: agent,
            currency: currency,
            state: .active
        )
    }
}

extension CustodialBalanceResponse {
    static let fullMock = CustodialBalanceResponse(
        btc: Balance(available: "0", pending: "0"),
        bch: Balance(available: "0", pending: "0"),
        eth: Balance(available: "200000", pending: "20000"),
        pax: Balance(available: "0", pending: "0"),
        xlm: Balance(available: "0", pending: "0")
    )
}

extension SimpleBuyPaymentAccountResponse.Agent {

    static let fullMock = SimpleBuyPaymentAccountResponse.Agent(
        account: "agent account",
        address: "agent address",
        code: "agent code",
        country: "agent country",
        name: "agent name",
        recipient: "agent recipient",
        routingNumber: "agent routingNumber"
    )

    static let emptyMock = SimpleBuyPaymentAccountResponse.Agent(
        account: nil,
        address: nil,
        code: nil,
        country: nil,
        name: nil,
        recipient: nil,
        routingNumber: nil
    )

    static let minimumGBPMock = SimpleBuyPaymentAccountResponse.Agent(
        account: "agent account",
        address: nil,
        code: "agent code",
        country: nil,
        name: nil,
        recipient: "agent recipient",
        routingNumber: nil
    )

    static let minimumEURMock = SimpleBuyPaymentAccountResponse.Agent(
        account: "agent account",
        address: nil,
        code: "agent code",
        country: nil,
        name: "agent name",
        recipient: nil,
        routingNumber: nil
    )

    static let idealEURMock = SimpleBuyPaymentAccountResponse.Agent(
        account: "agent account",
        address: nil,
        code: "agent code",
        country: "agent country",
        name: "agent name",
        recipient: "agent recipient",
        routingNumber: nil
    )
}
