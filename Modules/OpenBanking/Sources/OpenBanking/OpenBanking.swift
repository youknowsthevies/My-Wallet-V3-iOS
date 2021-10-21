// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineSchedulers
import Foundation
import NetworkKit
import Session
import ToolKit

// swiftlint:disable:next duplicate_imports
@_exported import struct ToolKit.Identity
// swiftlint:disable:next duplicate_imports
@_exported import protocol ToolKit.NewTypeString

public class OpenBanking {

    public typealias State = Session.State<Key>
    public private(set) var state: State

    public var scheduler: AnySchedulerOf<DispatchQueue>
    private var bag: Set<AnyCancellable> = []

    let requestBuilder: RequestBuilder
    let network: NetworkAdapterAPI

    let formatMoney: (_ amountMinor: String, _ symbol: String) -> String = { amountMinor, _ in amountMinor }

    public convenience init(
        requestBuilder: RequestBuilder,
        network: NetworkAdapterAPI,
        scheduler: DispatchQueue = .main
    ) {
        self.init(
            requestBuilder: requestBuilder,
            network: network,
            scheduler: scheduler.eraseToAnyScheduler(),
            state: .init()
        )
    }

    init(
        requestBuilder: RequestBuilder,
        network: NetworkAdapterAPI,
        scheduler: AnySchedulerOf<DispatchQueue>,
        state: State
    ) {
        self.requestBuilder = requestBuilder
        self.network = network
        self.scheduler = scheduler.eraseToAnyScheduler()
        self.state = state

        state.publisher(for: .consent.token, as: String.self)
            .sink(to: OpenBanking.handle(consent:), on: self)
            .store(in: &bag)
    }

    func handle(consent: Result<String, State.Error>) {
        do {

            if case .failure(.keyDoesNotExist) = consent {
                return
            }

            let request = try requestBuilder.post(
                path: state.get(.callback.path) as String,
                body: [
                    "oneTimeToken": consent.get()
                ].json(),
                authenticated: true
            )!

            network.perform(request: request)
                .mapError(Error.init)
                .result()
                .sink(to: OpenBanking.handle(updateConsent:), on: self)
                .store(in: &bag)
        } catch {
            state.set(.consent.error, to: error)
        }
    }

    func handle(updateConsent result: Result<Void, Error>) {

        state.transaction { state in
            switch result {
            case .success:
                state.clear(.consent.error)
                state.set(.is.authorised, to: true)
            case .failure(let error):
                state.set(.consent.error, to: error)
                state.set(.is.authorised, to: false)
            }
        }
    }

    public func createBankAccount() throws -> AnyPublisher<Result<BankAccount, Error>, Never> {
        let request = try requestBuilder.post(
            path: ["payments", "banktransfer"],
            body: [
                "currency": state.get(.currency) as String
            ].json(),
            authenticated: true
        )!

        return network.perform(request: request, responseType: BankAccount.self)
            .handleEvents(receiveOutput: { [state] output in
                state.set(.id, to: output.id)
            })
            .mapError(Error.init)
            .result()
    }

    public func allBankAccounts() -> AnyPublisher<Result<[BankAccount], Error>, Never> {

        let request = requestBuilder.get(
            path: ["payments", "banktransfer"],
            authenticated: true
        )!

        return network.perform(request: request, responseType: [BankAccount].self)
            .mapError(Error.init)
            .result()
    }
}

extension OpenBanking.BankAccount {

    public func activateBankAccount(
        with institution: Identity<OpenBanking.Institution>,
        in banking: OpenBanking
    ) throws -> AnyPublisher<Result<OpenBanking.BankAccount, OpenBanking.Error>, Never> {

        banking.state.transaction { state in
            state.clear(.authorisation.url)
            state.clear(.callback.path)
        }

        let request = try banking.requestBuilder.post(
            path: ["payments", "banktransfer", id.value, "update"],
            body: [
                "attributes": [
                    "institutionId": institution.value,
                    "callback": "https://blockchainwallet.page.link/oblinking"
                ]
            ].json(),
            authenticated: true
        )!

        return banking.network.perform(request: request, responseType: OpenBanking.BankAccount.self)
            .mapError(OpenBanking.Error.init)
            .result()
    }

    public func get(
        in banking: OpenBanking
    ) -> AnyPublisher<Result<OpenBanking.BankAccount, OpenBanking.Error>, Never> {

        let request = banking.requestBuilder.get(
            path: ["payments", "banktransfer", id.value],
            authenticated: true
        )!

        return banking.network.perform(request: request, responseType: OpenBanking.BankAccount.self)
            .handleEvents(receiveOutput: { [banking] details in
                guard let url = details.attributes.authorisationUrl else { return }
                guard let path = details.attributes.callbackPath else { return }
                banking.state.transaction { _ in
                    banking.state.set(.authorisation.url, to: url)
                    banking.state.set(.callback.path, to: path.dropPrefix("nabu-gateway").string)
                }
            })
            .mapError(OpenBanking.Error.init)
            .result()
    }

    public func poll(
        in banking: OpenBanking
    ) throws -> AnyPublisher<Result<OpenBanking.BankAccount, OpenBanking.Error>, Never> {
        Deferred {
            get(in: banking)
                .tryMap { result throws -> OpenBanking.BankAccount in
                    let account = try result.get()
                    guard account.error == nil else { return account }
                    guard account.state != "PENDING" else { throw OpenBankingRetry.timeout }
                    return account
                }
        }
        .retry(60, delay: .seconds(2), scheduler: banking.scheduler)
        .mapError(OpenBanking.Error.init)
        .result()
    }

    public func delete(
        in banking: OpenBanking
    ) -> AnyPublisher<Result<OpenBanking.BankAccount, OpenBanking.Error>, Never> {

        let request = banking.requestBuilder.delete(
            path: ["payments", "banktransfer", id.value],
            authenticated: true
        )!

        return banking.network.perform(request: request, responseType: OpenBanking.BankAccount.self)
            .handleEvents(receiveOutput: { [banking] _ in
                banking.state.clear(.id)
            })
            .mapError(OpenBanking.Error.init)
            .result()
    }

    public func pay(
        amountMinor: String,
        product: String,
        in banking: OpenBanking
    ) throws -> AnyPublisher<Result<OpenBanking.Payment, OpenBanking.Error>, Never> {

        let request = try banking.requestBuilder.post(
            path: ["payments", "banktransfer", id.value, "payment"],
            body: [
                "currency": banking.state.get(.currency) as String,
                "amountMinor": amountMinor,
                "product": product,
                "attributes": [
                    "callback": "https://blockchainwallet.page.link/obapproval"
                ]
            ].json(options: .sortedKeys),
            authenticated: true
        )!

        return banking.network.perform(request: request, responseType: OpenBanking.Payment.self)
            .handleEvents(receiveOutput: { [banking] payment in
                banking.state.set(.callback.path, to: payment.attributes.callbackPath.dropPrefix("nabu-gateway").string)
            })
            .mapError(OpenBanking.Error.init)
            .result()
    }
}

extension OpenBanking.Payment {

    public func get(in banking: OpenBanking) -> AnyPublisher<Result<Details, OpenBanking.Error>, Never> {

        let request = banking.requestBuilder.get(
            path: ["payments", "payment", id.value],
            authenticated: true
        )!

        return banking.network.perform(request: request, responseType: OpenBanking.Payment.Details.self)
            .handleEvents(receiveOutput: { [banking] details in
                guard let url = details.extraAttributes?.authorisationUrl else { return }
                banking.state.set(.authorisation.url, to: url)
            })
            .mapError(OpenBanking.Error.init)
            .result()
    }

    public func poll(in banking: OpenBanking) -> AnyPublisher<Result<Details, OpenBanking.Error>, Never> {
        Deferred {
            get(in: banking)
                .tryMap { result throws -> OpenBanking.Payment.Details in
                    let payment = try result.get()
                    guard payment.extraAttributes?.error == nil else { return payment }
                    guard payment.extraAttributes?.authorisationUrl != nil else { throw OpenBankingRetry.timeout }
                    return payment
                }
        }
        .retry(60, delay: .seconds(2), scheduler: banking.scheduler)
        .mapError(OpenBanking.Error.init)
        .result()
    }
}

public enum OpenBankingRetry: Error { case timeout }

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
            public var error: String?
            public var qrcodeUrl: URL?
            public var status: String?
        }

        public struct Amount: Codable, Hashable {
            public var symbol: String
            public var value: String
        }

        public let id: Identity<Self>
        public var amount: Amount
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

        public static let CREATED: Self = "CREATED"
        public static let ACTIVE: Self = "ACTIVE"
        public static let PENDING: Self = "PENDING"
        public static let BLOCKED: Self = "BLOCKED"
        public static let FRAUD_REVIEW: Self = "FRAUD_REVIEW"
        public static let MANUAL_REVIEW: Self = "MANUAL_REVIEW"
    }
}

extension OpenBanking.Payment.Details {

    public struct State: NewTypeString {

        public private(set) var value: String
        public init(_ value: String) { self.value = value }

        public static let CREATED: Self = "CREATED"
        public static let PRE_CHARGE_REVIEW: Self = "PRE_CHARGE_REVIEW"
        public static let AWAITING_AUTHORIZATION: Self = "AWAITING_AUTHORIZATION"
        public static let PRE_CHARGE_APPROVED: Self = "PRE_CHARGE_APPROVED"
        public static let PENDING: Self = "PENDING"
        public static let AUTHORIZED: Self = "AUTHORIZED"
        public static let CREDITED: Self = "CREDITED"
        public static let FAILED: Self = "FAILED"
        public static let FRAUD_REVIEW: Self = "FRAUD_REVIEW"
        public static let MANUAL_REVIEW: Self = "MANUAL_REVIEW"
        public static let REJECTED: Self = "REJECTED"
        public static let CLEARED: Self = "CLEARED"
        public static let COMPLETE: Self = "COMPLETE"
    }
}

extension OpenBanking.Error {
    public static let BANK_TRANSFER_ACCOUNT_ALREADY_LINKED: Self = .code("BANK_TRANSFER_ACCOUNT_ALREADY_LINKED")
    public static let BANK_TRANSFER_ACCOUNT_INFO_NOT_FOUND: Self = .code("BANK_TRANSFER_ACCOUNT_INFO_NOT_FOUND")
    public static let BANK_TRANSFER_ACCOUNT_NAME_MISMATCH: Self = .code("BANK_TRANSFER_ACCOUNT_NAME_MISMATCH")
    public static let BANK_TRANSFER_ACCOUNT_EXPIRED: Self = .code("BANK_TRANSFER_ACCOUNT_EXPIRED")
    public static let BANK_TRANSFER_ACCOUNT_REJECTED: Self = .code("BANK_TRANSFER_ACCOUNT_REJECTED")
    public static let BANK_TRANSFER_ACCOUNT_FAILED: Self = .code("BANK_TRANSFER_ACCOUNT_FAILED")
    public static let BANK_TRANSFER_ACCOUNT_INVALID: Self = .code("BANK_TRANSFER_ACCOUNT_INVALID")
}
