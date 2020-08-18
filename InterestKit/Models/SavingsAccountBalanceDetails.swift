//
//  SavingsAccountBalanceDetails.swift
//  InterestKit
//
//  Created by Alex McGregor on 8/6/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct SavingsAccountBalanceDetails: Decodable {
    
    public let balance: String?
    public let pendingInterest: String?
    public let totalInterest: String?
    public let pendingWithdrawal: String?
    public let pendingDeposit: String?
    public let fiatAmount: SymbolValue?
    
    private enum CodingKeys: String, CodingKey {
        case balance
        case pendingInterest
        case totalInterest
        case pendingWithdrawal
        case pendingDeposit
        case fiatAmount
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        balance = try values.decodeIfPresent(String.self, forKey: .balance)
        pendingDeposit = try values.decodeIfPresent(String.self, forKey: .pendingDeposit)
        pendingInterest = try values.decodeIfPresent(String.self, forKey: .pendingInterest)
        pendingWithdrawal = try values.decodeIfPresent(String.self, forKey: .pendingWithdrawal)
        totalInterest = try values.decodeIfPresent(String.self, forKey: .totalInterest)
        fiatAmount = try values.decodeIfPresent(SymbolValue.self, forKey: .fiatAmount)
    }
}

public extension SavingsAccountBalanceDetails {
    var fiatValue: FiatValue? {
        guard let amount = fiatAmount else { return nil }
        guard let fiatCurrency = FiatCurrency(code: amount.symbol) else {
            return nil
        }
        return .create(amountString: amount.value, currency: fiatCurrency)
    }
}
