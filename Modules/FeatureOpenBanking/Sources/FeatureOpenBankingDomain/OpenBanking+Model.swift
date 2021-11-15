// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

extension OpenBanking {

    public struct BankAccount: Codable, Hashable {

        public struct Attributes: Codable, Hashable {

            public var callbackPath: String?
            public var entity: String
            public var media: [Media]?
            public var qrCodeUrl: URL?
            public var authorisationUrl: URL?
            public var institutions: [Institution]?

            public init(
                callbackPath: String? = nil,
                entity: String,
                media: [OpenBanking.Media]? = nil,
                qrCodeUrl: URL? = nil,
                authorisationUrl: URL? = nil,
                institutions: [OpenBanking.Institution]? = nil
            ) {
                self.callbackPath = callbackPath
                self.entity = entity
                self.media = media
                self.qrCodeUrl = qrCodeUrl
                self.authorisationUrl = authorisationUrl
                self.institutions = institutions
            }
        }

        public struct Details: Codable, Hashable {

            public var bankAccountType: String?
            public var routingNumber: String?
            public var accountNumber: String?
            public var accountName: String?
            public var bankName: String?
            public var sortCode: String?
            public var iban: String?
            public var bic: String?

            public init(
                bankAccountType: String? = nil,
                routingNumber: String? = nil,
                accountNumber: String? = nil,
                accountName: String? = nil,
                bankName: String? = nil,
                sortCode: String? = nil,
                iban: String? = nil,
                bic: String? = nil
            ) {
                self.bankAccountType = bankAccountType
                self.routingNumber = routingNumber
                self.accountNumber = accountNumber
                self.accountName = accountName
                self.bankName = bankName
                self.sortCode = sortCode
                self.iban = iban
                self.bic = bic
            }
        }

        public let id: Identity<Self>
        public var partner: String
        public var state: State?
        public var currency: String?
        public var details: Details?
        public var error: OpenBanking.Error?
        public var attributes: Attributes
        public var addedAt: String?

        public init(
            id: Identity<OpenBanking.BankAccount>,
            partner: String,
            state: State? = nil,
            currency: String? = nil,
            details: OpenBanking.BankAccount.Details? = nil,
            error: OpenBanking.Error? = nil,
            attributes: OpenBanking.BankAccount.Attributes,
            addedAt: String? = nil
        ) {
            self.id = id
            self.partner = partner
            self.state = state
            self.currency = currency
            self.details = details
            self.error = error
            self.attributes = attributes
            self.addedAt = addedAt
        }
    }

    public struct Payment: Codable, Hashable {

        public struct Attributes: Codable, Hashable {
            public var callbackPath: String
        }

        public var id: Identity<Self> { paymentId }
        public let paymentId: Identity<Self>
        public var attributes: Attributes
    }

    public struct Media: Codable, Hashable {
        public var source: URL
        public var type: MediaType
    }

    public struct Institution: Codable, Hashable {

        public struct Country: Codable, Hashable {
            public var displayName: String
            public var countryCode2: String
        }

        public let id: Identity<Self>
        public var name: String
        public var fullName: String
        public var media: [Media]
        public var countries: [Country]
        public var credentialsType: String
        public var environmentType: String
        public var features: [String]
    }

    public struct Order: Codable, Hashable {

        public init(
            id: Identity<OpenBanking.Order>,
            state: OpenBanking.Order.State,
            inputCurrency: String,
            inputQuantity: String,
            outputCurrency: String,
            outputQuantity: String,
            price: String?,
            paymentMethodId: String,
            paymentType: String,
            attributes: OpenBanking.Order.Attributes = .init()
        ) {
            self.id = id
            self.state = state
            self.inputCurrency = inputCurrency
            self.inputQuantity = inputQuantity
            self.outputCurrency = outputCurrency
            self.outputQuantity = outputQuantity
            self.price = price
            self.paymentMethodId = paymentMethodId
            self.paymentType = paymentType
            self.attributes = attributes
        }

        public struct Attributes: Codable, Hashable {

            public init(
                callbackPath: String? = nil,
                qrCodeUrl: URL? = nil,
                authorisationUrl: URL? = nil,
                consentId: String? = nil,
                expiresAt: String? = nil
            ) {
                self.callbackPath = callbackPath
                self.qrCodeUrl = qrCodeUrl
                self.authorisationUrl = authorisationUrl
                self.consentId = consentId
                self.expiresAt = expiresAt
            }

            public var callbackPath: String?
            public var qrCodeUrl: URL?
            public var authorisationUrl: URL?
            public var consentId: String?
            public var expiresAt: String?
        }

        public var id: Identity<Self>
        public var state: State
        public var inputCurrency: String
        public var inputQuantity: String
        public var outputCurrency: String
        public var outputQuantity: String
        public var price: String?
        public var paymentMethodId: String
        public var paymentType: String
        public var attributes: Attributes? = .init()
    }
}

extension OpenBanking.Order {

    public struct State: NewTypeString {

        public private(set) var value: String

        public init(_ value: String) { self.value = value }

        public static let pendingDeposit: Self = "PENDING_DEPOSIT"
        public static let pendingConfirmation: Self = "PENDING_CONFIRMATION"
        public static let canceled: Self = "CANCELED"
        public static let depositMatched: Self = "DEPOSIT_MATCHED"
        public static let failed: Self = "FAILED"
        public static let expired: Self = "EXPIRED"
        public static let finished: Self = "FINISHED"
    }
}

extension OpenBanking.Media {

    public struct MediaType: NewTypeString {

        public private(set) var value: String

        public init(_ value: String) { self.value = value }

        public static let icon: Self = "icon"
        public static let logo: Self = "logo"
    }
}

extension OpenBanking.Payment {

    public struct Details: Codable, Hashable {

        public struct ExtraAttributes: Codable, Hashable {
            public var authorisationUrl: URL?
            public var error: OpenBanking.Error?
            public var qrcodeUrl: URL?
            public var status: String?
        }

        public struct Amount: Codable, Hashable {
            public var symbol: String
            public var value: String
        }

        public let id: Identity<Self>
        public var amount: Amount
        public var amountMinor: String
        public var extraAttributes: ExtraAttributes?
        public var insertedAt: String
        public var state: State
        public var type: String
        public var createdAt: String?
        public var txHash: String?
        public var beneficiaryId: String
    }
}

extension OpenBanking.BankAccount {

    public struct State: NewTypeString {

        public private(set) var value: String

        public init(_ value: String) { self.value = value }

        public static let created: Self = "CREATED"
        public static let active: Self = "ACTIVE"
        public static let pending: Self = "PENDING"
        public static let blocked: Self = "BLOCKED"
        public static let fraudReview: Self = "FRAUD_REVIEW"
        public static let manualReview: Self = "MANUAL_REVIEW"
    }
}

extension OpenBanking.Payment.Details {

    public struct State: NewTypeString {

        public private(set) var value: String

        public init(_ value: String) { self.value = value }

        public static let created: Self = "CREATED"
        public static let preChargeReview: Self = "PRE_CHARGE_REVIEW"
        public static let awaitingAuthorization: Self = "AWAITING_AUTHORIZATION"
        public static let preChargeApproved: Self = "PRE_CHARGE_APPROVED"
        public static let pending: Self = "PENDING"
        public static let authorized: Self = "AUTHORIZED"
        public static let credited: Self = "CREDITED"
        public static let failed: Self = "FAILED"
        public static let fraudReview: Self = "FRAUD_REVIEW"
        public static let manualReview: Self = "MANUAL_REVIEW"
        public static let rejected: Self = "REJECTED"
        public static let cleared: Self = "CLEARED"
        public static let complete: Self = "COMPLETE"
    }
}

extension OpenBanking.Error {
    public static let bankTransferAccountAlreadyLinked: Self = .code("BANK_TRANSFER_ACCOUNT_ALREADY_LINKED")
    public static let bankTransferAccountInfoNotFound: Self = .code("BANK_TRANSFER_ACCOUNT_INFO_NOT_FOUND")
    public static let bankTransferAccountNameMismatch: Self = .code("BANK_TRANSFER_ACCOUNT_NAME_MISMATCH")
    public static let bankTransferAccountExpired: Self = .code("BANK_TRANSFER_ACCOUNT_EXPIRED")
    public static let bankTransferAccountRejected: Self = .code("BANK_TRANSFER_ACCOUNT_REJECTED")
    public static let bankTransferAccountFailed: Self = .code("BANK_TRANSFER_ACCOUNT_FAILED")
    public static let bankTransferAccountInvalid: Self = .code("BANK_TRANSFER_ACCOUNT_INVALID")
    public static let bankTransferAccountNotSupported: Self = .code("BANK_TRANSFER_ACCOUNT_NOT_SUPPORTED")
    public static let bankTransferAccountFailedInternal: Self = .code("BANK_TRANSFER_ACCOUNT_FAILED_INTERNAL")
    public static let bankTransferAccountRejectedFraud: Self = .code("BANK_TRANSFER_ACCOUNT_REJECTED_FRAUD")
}
