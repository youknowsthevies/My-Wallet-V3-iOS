// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinCashKit
import DIKit
import NetworkKit
import PlatformKit
import RxSwift
import SettingsKit

protocol ExchangeClientAPI {
    typealias LinkID = String
    
    var linkID: Single<LinkID> { get }
    func linkToExistingExchangeUser(linkID: LinkID) -> Completable
    func syncDepositAddress(accounts: [AssetAddress]) -> Completable
}

final class ExchangeClient: ExchangeClientAPI {
    
    private let networkAdapter: NetworkAdapterAPI
    private let appSettings: BlockchainSettings.App
    
    init(networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail),
         settings: BlockchainSettings.App = resolve()) {
        self.networkAdapter = networkAdapter
        self.appSettings = settings
    }
    
    var linkID: Single<LinkID> {
        let fallback = fetchLinkIDPayload()
            .flatMap(weak: self) { (self, payload) -> Single<LinkID> in
                guard let linkID = payload["linkId"] else {
                return Single.error(ExchangeLinkingAPIError.noLinkID)
            }
            
            return Single.just(linkID)
        }
        return existingUserLinkIdentifier().ifEmpty(switchTo: fallback)
    }
    
    func syncDepositAddress(accounts: [AssetAddress]) -> Completable {
        let depositAddresses: Dictionary<String, String> = Dictionary(accounts.map { account in
            if let bitcoinCashAddress = account as? BitcoinCashAssetAddress {
                let depositAddress = bitcoinCashAddress.publicKey.removing(prefix: "\(AssetConstants.URLSchemes.bitcoinCash):")
                return (bitcoinCashAddress.cryptoCurrency.code, depositAddress)
            } else {
                return (account.cryptoCurrency.code, account.publicKey)
            }
        }) { _, last in last }
        let payload = ["addresses" : depositAddresses ]
        let apiURL = URL(string: BlockchainAPI.shared.retailCoreUrl)!
        let components = ["users", "deposit", "addresses"]
        let endpoint = URL.endpoint(apiURL, pathComponents: components)!
        let request = NetworkRequest(
            endpoint: endpoint,
            method: .post,
            body: try? JSONEncoder().encode(payload),
            authenticated: true,
            contentType: .json
        )
        return networkAdapter
            .perform(
                request: request,
                errorResponseType: NabuNetworkError.self
            )
    }
    
    func linkToExistingExchangeUser(linkID: LinkID) -> Completable {
        let payload = ["linkId": linkID]
        let apiURL = URL(string: BlockchainAPI.shared.retailCoreUrl)!
        let components = ["users", "link-account", "existing"]
        let endpoint = URL.endpoint(apiURL, pathComponents: components)!
        let request = NetworkRequest(
            endpoint: endpoint,
            method: .put,
            body: try? JSONEncoder().encode(payload),
            authenticated: true,
            contentType: .json
        )
        return networkAdapter
            .perform(
                request: request,
                errorResponseType: NabuNetworkError.self
            )
    }
    
    func fetchLinkIDPayload() -> Single<Dictionary<String, String>> {
        let apiURL = URL(string: BlockchainAPI.shared.retailCoreUrl)!
        let components = ["users", "link-account", "create", "start"]
        let endpoint = URL.endpoint(apiURL, pathComponents: components)!
        let request = NetworkRequest(
            endpoint: endpoint,
            method: .put,
            body: nil,
            authenticated: true,
            contentType: .json
        )
        return networkAdapter
            .perform(
                request: request,
                errorResponseType: NabuNetworkError.self
            )
    }
    
    private func existingUserLinkIdentifier() -> Maybe<LinkID> {
        if let identifier = appSettings.exchangeLinkIdentifier {
            return Maybe.just(identifier)
        } else {
            return Maybe.empty()
        }
    }
}
