// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import PlatformKit

enum StellarHistoricalTransaction {

    public var fee: CryptoValue? {
        switch self {
        case .accountCreated(let value):
            guard let fee = value.fee else { return nil }
            return CryptoValue(amount: BigInt(fee), currency: .stellar)
        case .payment(let value):
            guard let fee = value.fee else { return nil }
            return CryptoValue(amount: BigInt(fee), currency: .stellar)
        }
    }

    public var memo: String? {
        switch self {
        case .accountCreated(let value):
            return value.memo
        case .payment(let value):
            return value.memo
        }
    }

    /**
     The transaction identifier, used for equality checking and backend calls.

     - Note:
        For Stellar, this is different than `transactionHash`.
        See [Stellar Operation Object](https://developers.stellar.org/api/resources/operations/object/) for more info.
     */
    public var identifier: String {
        switch self {
        case .accountCreated(let value):
            return value.identifier
        case .payment(let value):
            return value.identifier
        }
    }

    public var fromAddress: StellarAssetAddress {
        switch self {
        case .accountCreated(let value):
            return StellarAssetAddress(publicKey: value.funder)
        case .payment(let value):
            return StellarAssetAddress(publicKey: value.fromAccount)
        }
    }

    public var toAddress: StellarAssetAddress {
        switch self {
        case .accountCreated(let value):
            return StellarAssetAddress(publicKey: value.account)
        case .payment(let value):
            return StellarAssetAddress(publicKey: value.toAccount)
        }
    }

    public var direction: Direction {
        switch self {
        case .accountCreated(let value):
            return value.direction
        case .payment(let value):
            return value.direction
        }
    }

    public var amount: CryptoValue {
        CryptoValue.create(majorDisplay: amountString, currency: .stellar) ?? .zero(currency: .stellar)
    }

    private var amountString: String {
        switch self {
        case .accountCreated(let value):
            return String(describing: value.balance)
        case .payment(let value):
            return value.amount
        }
    }

    /// The transaction hash, used in Explorer URLs.
    public var transactionHash: String {
        switch self {
        case .accountCreated(let value):
            return value.transactionHash
        case .payment(let value):
            return value.transactionHash
        }
    }

    public var createdAt: Date {
        switch self {
        case .accountCreated(let value):
            return value.createdAt
        case .payment(let value):
            return value.createdAt
        }
    }

    case accountCreated(AccountCreated)
    case payment(Payment)

    /**
     Historical transaction representing the creation of an account.
     See [Stellar Create Account Object](https://developers.stellar.org/api/resources/operations/object/create-account/) for more info.
     */
    public struct AccountCreated {

        /// The transaction identifier, used for equality checking and backend calls.
        let identifier: String

        /// The transaction paging token, used for pagination.
        let pagingToken: String

        let funder: String
        let account: String
        let direction: Direction
        let balance: Decimal
        let sourceAccountID: String

        /// The transaction hash, used in Explorer URLs.
        let transactionHash: String

        let createdAt: Date
        var fee: Int?
        var memo: String?
    }

    /**
     Historical transaction representing a payment.
     See [Stellar Payment Object](https://developers.stellar.org/api/resources/operations/object/payment/) for more info.
     */
    public struct Payment {

        /// The transaction identifier, used for equality checking and backend calls.
        let identifier: String

        /// The transaction paging token, used for pagination.
        let pagingToken: String

        let fromAccount: String
        let toAccount: String
        let direction: Direction
        let amount: String

        /// The transaction hash, used in Explorer URLs.
        let transactionHash: String

        let createdAt: Date
        var fee: Int?
        var memo: String?
    }
}
