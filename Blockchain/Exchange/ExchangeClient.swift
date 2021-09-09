// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinCashKit
import Combine
import DIKit
import FeatureSettingsDomain
import NabuNetworkError
import NetworkKit
import PlatformKit
import ToolKit

protocol ExchangeClientAPI {
    typealias LinkID = String

    var linkID: AnyPublisher<LinkID, Error> { get }

    func linkToExistingExchangeUser(
        linkID: LinkID
    ) -> AnyPublisher<Void, NabuNetworkError>

    func syncDepositAddress(
        accounts: [CryptoReceiveAddress]
    ) -> AnyPublisher<Void, NabuNetworkError>
}

final class ExchangeClient: ExchangeClientAPI {

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI
    private let appSettings: BlockchainSettings.App

    init(
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail),
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail),
        settings: BlockchainSettings.App = resolve()
    ) {
        self.requestBuilder = requestBuilder
        self.networkAdapter = networkAdapter
        appSettings = settings
    }

    var linkID: AnyPublisher<LinkID, Error> {
        let fallback: AnyPublisher<LinkID, Error> = fetchLinkIDPayload()
            .eraseError()
            .flatMap { payload -> AnyPublisher<LinkID, Error> in
                guard let linkID = payload["linkId"] else {
                    return .failure(ExchangeLinkingAPIError.noLinkID)
                }

                return .just(linkID)
            }
            .eraseToAnyPublisher()
        return existingUserLinkIdentifier()
            .flatMap { linkId -> AnyPublisher<LinkID, Error> in
                guard let linkId = linkId else {
                    return fallback
                }
                return .just(linkId)
            }
            .eraseToAnyPublisher()
    }

    func syncDepositAddress(
        accounts: [CryptoReceiveAddress]
    ) -> AnyPublisher<Void, NabuNetworkError> {
        let depositAddresses = accounts
            .reduce(into: [String: String]()) { result, receiveAddress in
                result[receiveAddress.asset.code] = receiveAddress.address
            }
        let payload = ["addresses": depositAddresses]
        let request = requestBuilder.post(
            path: ["users", "deposit", "addresses"],
            body: try? JSONEncoder().encode(payload),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    func linkToExistingExchangeUser(
        linkID: LinkID
    ) -> AnyPublisher<Void, NabuNetworkError> {
        let payload = ["linkId": linkID]
        let path = ["users", "link-account", "existing"]
        let request = requestBuilder.put(
            path: path,
            body: try? JSONEncoder().encode(payload),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    func fetchLinkIDPayload() -> AnyPublisher<[String: String], NabuNetworkError> {
        let path = ["users", "link-account", "create", "start"]
        let request = requestBuilder.put(
            path: path,
            body: nil,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    private func existingUserLinkIdentifier() -> AnyPublisher<LinkID?, Never> {
        .just(appSettings.exchangeLinkIdentifier)
    }
}
