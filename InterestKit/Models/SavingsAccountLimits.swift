//
//  SavingsAccountLimits.swift
//  InterestKit
//
//  Created by Alex McGregor on 8/11/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import PlatformKit

public struct SavingsAccountLimitsResponse: Decodable {

    public static let empty = SavingsAccountLimitsResponse()

    // MARK: - Properties

   private let limits: [String: SavingsAccountLimits]

    // MARK: - Init

    private init() {
        limits = [:]
    }
    
    private enum CodingKeys: String, CodingKey {
        case limits
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        limits = try values.decode([String: SavingsAccountLimits].self, forKey: .limits)
    }

    // MARK: - Subscript

    subscript(currency: CryptoCurrency) -> SavingsAccountLimits? {
        limits[currency.rawValue]
    }
}


public struct SavingsAccountLimits: Decodable {
    
    public let currency: FiatCurrency
    public let lockUpDuration: Double
    public let maxWithdrawalAmount: FiatValue
    public let minDepositAmount: FiatValue
    
    private enum CodingKeys: String, CodingKey {
        case currency
        case lockUpDuration
        case maxWithdrawalAmount
        case minDepositAmount
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let currencyValue = try values.decode(String.self, forKey: .currency)
        currency = FiatCurrency(code: currencyValue) ?? .USD
        lockUpDuration = try values.decode(Double.self, forKey: .lockUpDuration)
        let withdrawal = try values.decode(String.self, forKey: .maxWithdrawalAmount)
        let deposit = try values.decode(String.self, forKey: .minDepositAmount)
        let zero = FiatValue.zero(currency: currency)
        maxWithdrawalAmount = FiatValue.create(minor: withdrawal, currency: currency) ?? zero
        minDepositAmount = FiatValue.create(minor: deposit, currency: currency) ?? zero
    }
}

public extension SavingsAccountLimits {
    var lockupDescription: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day]
        formatter.unitsStyle = .short
        // NOTE: `lockUpDuration` is in seconds. Staging returns `Two Hours`.
        // So in Staging the value will show as `O Days`
        return formatter.string(from: TimeInterval(lockUpDuration))?.capitalized ?? ""
    }
}
