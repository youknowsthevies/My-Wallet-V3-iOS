// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureInterestDomain

public struct InterestAccountBalanceDetailsResponse: Decodable {

    public let balance: String?
    public let pendingInterest: String?
    public let lockedBalance: String?
    public let totalInterest: String?
    public let pendingWithdrawal: String?
    public let pendingDeposit: String?

    private enum CodingKeys: String, CodingKey {
        case balance
        case pendingInterest
        case totalInterest
        case locked
        case pendingWithdrawal
        case pendingDeposit
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        balance = try values.decodeIfPresent(String.self, forKey: .balance)
        lockedBalance = try values.decodeIfPresent(String.self, forKey: .locked)
        pendingDeposit = try values.decodeIfPresent(String.self, forKey: .pendingDeposit)
        pendingInterest = try values.decodeIfPresent(String.self, forKey: .pendingInterest)
        pendingWithdrawal = try values.decodeIfPresent(String.self, forKey: .pendingWithdrawal)
        totalInterest = try values.decodeIfPresent(String.self, forKey: .totalInterest)
    }
}

extension InterestAccountBalanceDetails {
    init(_ response: InterestAccountBalanceDetailsResponse, code: String) {
        self.init(
            balance: response.balance,
            pendingInterest: response.pendingInterest,
            locked: response.lockedBalance,
            totalInterest: response.totalInterest,
            pendingWithdrawal: response.pendingWithdrawal,
            pendingDeposit: response.pendingDeposit,
            code: code
        )
    }
}
