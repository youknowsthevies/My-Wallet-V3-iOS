//
//  SwapActivityItemEvent.swift
//  PlatformKit
//
//  Created by Alex McGregor on 4/27/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization

public struct SwapActivityItemEvent: Decodable, Tokenized {
    
    enum SwapActivityItemEventError: Error {
        case decodingError
    }
    
    public let identifier: String
    public let status: EventStatus
    public let date: Date
    public let pair: Pair
    public let addresses: Addresses
    public let amounts: Amounts
    public let withdrawalTxHash: String?
    public let depositTxHash: String?
    
    public var token: String {
        identifier
    }
    
    public struct Pair {
        public let to: CryptoCurrency
        public let from: CryptoCurrency
        
        init(to: CryptoCurrency, from: CryptoCurrency) {
            self.to = to
            self.from = from
        }
        
        init(string: String) throws {
            
            var components: [String] = []
            for value in ["-", "_"] {
                if string.contains(value) {
                    components = string.components(separatedBy: value)
                    break
                }
            }
            
            guard let from = components.first else { throw SwapActivityItemEventError.decodingError }
            guard let to = components.last else { throw SwapActivityItemEventError.decodingError }
            guard let toAsset = CryptoCurrency(code: to) else { throw SwapActivityItemEventError.decodingError }
            guard let fromAsset = CryptoCurrency(code: from) else { throw SwapActivityItemEventError.decodingError }
            
            self.init(to: toAsset, from: fromAsset)
        }
    }
    
    public struct Addresses {
        public let refundAddress: String
        public let depositAddress: String
        public let withdrawalAddress: String
        
        public init(refund: String, deposit: String, withdrawal: String) {
            self.refundAddress = refund
            self.depositAddress = deposit
            self.withdrawalAddress = withdrawal
        }
    }
    
    public struct Amounts {
        public let deposit: CryptoValue
        public let withdrawal: CryptoValue
        public let withdrawalFee: CryptoValue
        public let fiatValue: FiatValue
        
        init(deposit: CryptoValue, withdrawal: CryptoValue, withdrawalFee: CryptoValue, fiatValue: FiatValue) {
            self.deposit = deposit
            self.withdrawal = withdrawal
            self.withdrawalFee = withdrawalFee
            self.fiatValue = fiatValue
        }
    }
    
    public enum EventStatus {
        case inProgress(ProgressStatus)
        case pendingRefund
        case refunded
        case failed
        case expired
        case delayed
        case complete
        case none
        
        public enum ProgressStatus: String {
            case pendingExecution = "PENDING_EXECUTION"
            case pendingDeposit = "PENDING_DEPOSIT"
            case finishedDeposit = "FINISHED_DEPOSIT"
            case pendingWithdrawal = "PENDING_WITHDRAWAL"
        }
        
        public var localizedDescription: String {
            switch self {
            case .complete:
                return LocalizationConstants.Swap.complete
            case .delayed:
                return LocalizationConstants.Swap.delayed
            case .pendingRefund:
                return LocalizationConstants.Swap.refundInProgress
            case .refunded:
                return LocalizationConstants.Swap.refunded
            case .failed:
                return LocalizationConstants.Swap.failed
            case .expired:
                return LocalizationConstants.Swap.expired
            case .inProgress,
                 .none:
                return LocalizationConstants.Swap.inProgress
            }
        }
        
        public init(value: String) {
            switch value {
            case "NONE":
                self = .none
            case "PENDING_EXECUTION":
                self = .inProgress(.pendingExecution)
            case "PENDING_DEPOSIT":
                self = .inProgress(.pendingDeposit)
            case "FINISHED_DEPOSIT":
                self = .inProgress(.finishedDeposit)
            case "PENDING_WITHDRAWAL":
                self = .inProgress(.pendingWithdrawal)
            case "PENDING_REFUND":
                self = .pendingRefund
            case "REFUNDED":
                self = .refunded
            case "FINISHED":
                self = .complete
            case "FAILED":
                self = .failed
            case "EXPIRED":
                self = .expired
            case "DELAYED":
                self = .delayed
            default:
                self = .none
            }
        }
    }

    private struct SymbolValue: Decodable {
        let symbol: String
        let value: String
    }

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case status = "state"
        case createdAt
        case pair
        case refundAddress
        case depositAddress
        case deposit
        case withdrawalAddress
        case withdrawal
        case withdrawalFee
        case fiatValue
        case depositTxHash
        case withdrawalTxHash
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let createdAt = try values.decode(String.self, forKey: .createdAt)
        let formatter = DateFormatter.sessionDateFormat
        let legacyFormatter = DateFormatter.iso8601Format
        
        /// Some trades don't have a consistant date format. Some
        /// use the same format as what we use for establishing a
        /// secure session, some use ISO8601.
        if let value = formatter.date(from: createdAt) {
            date = value
        } else if let value = legacyFormatter.date(from: createdAt) {
            date = value
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .createdAt,
                in: values,
                debugDescription: "Date string does not match format expected by formatter."
            )
        }
        
        identifier = try values.decode(String.self, forKey: .identifier)
        let pairValue = try values.decode(String.self, forKey: .pair)
        
        let statusValue = try values.decode(String.self, forKey: .status)
        status = EventStatus(value: statusValue)
        pair = try Pair(string: pairValue)
        let refundAddress = try values.decode(String.self, forKey: .refundAddress)
        let depositAddress = try values.decode(String.self, forKey: .depositAddress)
        let withdrawalAddress = try values.decode(String.self, forKey: .withdrawalAddress)
        
        addresses = .init(
            refund: refundAddress,
            deposit: depositAddress,
            withdrawal: withdrawalAddress
        )

        let deposit = try values.decode(SymbolValue.self, forKey: .deposit)
        guard let depositCryptoCurrency = CryptoCurrency(code: deposit.symbol) else {
            throw SwapActivityItemEventError.decodingError
        }
        guard let depositCryptoValue = CryptoValue.createFromMajorValue(string: deposit.value, assetType: depositCryptoCurrency) else {
            throw SwapActivityItemEventError.decodingError
        }

        let withdrawal = try values.decode(SymbolValue.self, forKey: .withdrawal)
        guard let withdrawalCryptoCurrency = CryptoCurrency(code: withdrawal.symbol) else {
            throw SwapActivityItemEventError.decodingError
        }
        guard let withdrawalCryptoValue = CryptoValue.createFromMajorValue(string: withdrawal.value, assetType: withdrawalCryptoCurrency) else {
            throw SwapActivityItemEventError.decodingError
        }
        
        let withdrawalFee = try values.decode(SymbolValue.self, forKey: .withdrawalFee)
        guard let withdrawalFeeCryptoCurrency = CryptoCurrency(code: withdrawalFee.symbol) else {
            throw SwapActivityItemEventError.decodingError
        }
        guard let withdrawalFeeCryptoValue = CryptoValue.createFromMajorValue(
            string: withdrawalFee.value,
            assetType: withdrawalFeeCryptoCurrency) else {
            throw SwapActivityItemEventError.decodingError
        }
        
        let fiatValueContainer = try values.decode(SymbolValue.self, forKey: .fiatValue)
        guard let fiatCurrency = FiatCurrency(code: fiatValueContainer.symbol) else {
            throw SwapActivityItemEventError.decodingError
        }
        let fiatValue = FiatValue.create(amountString: fiatValueContainer.value, currency: fiatCurrency, locale: .US)

        self.amounts = Amounts(deposit: depositCryptoValue, withdrawal: withdrawalCryptoValue, withdrawalFee: withdrawalFeeCryptoValue, fiatValue: fiatValue)
        depositTxHash = try values.decodeIfPresent(String.self, forKey: .depositTxHash)
        withdrawalTxHash = try values.decodeIfPresent(String.self, forKey: .withdrawalTxHash)
    }
}

extension SwapActivityItemEvent: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

extension SwapActivityItemEvent: Equatable {
    public static func == (lhs: SwapActivityItemEvent, rhs: SwapActivityItemEvent) -> Bool {
        lhs.identifier == rhs.identifier &&
            lhs.status == rhs.status &&
            lhs.date == rhs.date &&
            lhs.pair == rhs.pair &&
            lhs.addresses == rhs.addresses &&
            lhs.amounts == rhs.amounts &&
            lhs.withdrawalTxHash == rhs.withdrawalTxHash &&
            lhs.depositTxHash == rhs.depositTxHash
    }
}

extension SwapActivityItemEvent.EventStatus: Equatable {
    public static func == (lhs: SwapActivityItemEvent.EventStatus,
                           rhs: SwapActivityItemEvent.EventStatus) -> Bool {
        switch (lhs, rhs) {
        case (.inProgress(let left), .inProgress(let right)):
            return left == right
        case (.pendingRefund, .pendingRefund),
             (.refunded, .refunded),
             (.failed, .failed),
             (.expired, .expired),
             (.delayed, .delayed),
             (.complete, .complete),
             (.none, .none):
            return true
        default:
            return false
        }
    }
}

extension SwapActivityItemEvent.Pair: Equatable {
    public static func == (lhs: SwapActivityItemEvent.Pair, rhs: SwapActivityItemEvent.Pair) -> Bool {
        lhs.to == rhs.to &&
            lhs.from == rhs.from
    }
}

extension SwapActivityItemEvent.Addresses: Equatable {
    public static func == (lhs: SwapActivityItemEvent.Addresses, rhs: SwapActivityItemEvent.Addresses) -> Bool {
        lhs.depositAddress == rhs.depositAddress &&
            lhs.refundAddress == rhs.refundAddress &&
            lhs.withdrawalAddress == rhs.withdrawalAddress
    }
}

extension SwapActivityItemEvent.Amounts: Equatable {
    public static func == (lhs: SwapActivityItemEvent.Amounts, rhs: SwapActivityItemEvent.Amounts) -> Bool {
        lhs.deposit == rhs.deposit &&
            lhs.fiatValue == rhs.fiatValue &&
            lhs.withdrawal == rhs.withdrawal &&
            lhs.withdrawalFee == rhs.withdrawalFee
    }
}
