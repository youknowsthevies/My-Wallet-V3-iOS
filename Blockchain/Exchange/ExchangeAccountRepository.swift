//
//  ExchangeAccountRepository.swift
//  Blockchain
//
//  Created by AlexM on 7/5/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinKit
import NetworkKit
import PlatformKit
import RxSwift

protocol ExchangeAccountRepositoryAPI {
    var hasLinkedExchangeAccount: Single<Bool> { get }
    func syncDepositAddresses() -> Completable
    func syncDepositAddressesIfLinked() -> Completable
}

protocol ExchangeClientAPI {
    typealias LinkID = String
    
    var appSettings: BlockchainSettings.App { get }
    var communicatorAPI: NetworkCommunicatorAPI { get }
    var linkID: Single<LinkID> { get }
    func linkToExistingExchangeUser(linkID: LinkID) -> Completable
    func syncDepositAddress(accounts: [AssetAddress]) -> Completable
}

enum ExchangeLinkingAPIError: Error {
    case noLinkID
    case `unknown`
}

class ExchangeAccountRepository: ExchangeAccountRepositoryAPI {
    
    private let blockchainRepository: BlockchainDataRepository
    private let clientAPI: ExchangeClientAPI
    private let accountRepository: AssetAccountRepositoryAPI
    
    init(blockchainRepository: BlockchainDataRepository = BlockchainDataRepository.shared,
         clientAPI: ExchangeClientAPI = ExchangeClient(communicatorAPI: Network.Dependencies.retail.communicator),
         accountRepository: AssetAccountRepositoryAPI = AssetAccountRepository.shared) {
        self.blockchainRepository = blockchainRepository
        self.clientAPI = clientAPI
        self.accountRepository = accountRepository
    }
    
    var hasLinkedExchangeAccount: Single<Bool> {
        blockchainRepository
            .fetchNabuUser()
            .flatMap(weak: self, { (self, user) -> Single<Bool> in
                Single.just(user.hasLinkedExchangeAccount)
        })
    }
    
    func syncDepositAddressesIfLinked() -> Completable {
        hasLinkedExchangeAccount.flatMapCompletable(weak: self, { (self, linked) -> Completable in
            if linked {
                return self.syncDepositAddresses()
            } else {
                return Completable.empty()
            }
        })
    }
    
    func syncDepositAddresses() -> Completable {
        accountRepository.accounts
            .flatMapCompletable(weak: self) { (self, accounts) -> Completable in
                let addresses = accounts.map { $0.address }
                return self.clientAPI.syncDepositAddress(accounts: addresses)
            }
    }
}

class ExchangeClient: ExchangeClientAPI {
    var communicatorAPI: NetworkCommunicatorAPI
    var appSettings: BlockchainSettings.App
    
    init(communicatorAPI: NetworkCommunicatorAPI = Network.Dependencies.retail.communicator,
         settings: BlockchainSettings.App = BlockchainSettings.App.shared) {
        self.communicatorAPI = communicatorAPI
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
                let depositAddress = bitcoinCashAddress.publicKey.removing(prefix: "\(Constants.Schemes.bitcoinCash):")
                return (bitcoinCashAddress.cryptoCurrency.code, depositAddress)
            } else {
                return (account.cryptoCurrency.code, account.publicKey)
            }
        }) { _, last in last }
        let payload = ["addresses" : depositAddresses ]
        guard let apiURL = URL(string: BlockchainAPI.shared.retailCoreUrl) else {
            return Completable.error(NetworkError.default)
        }
        let components = ["users", "deposit", "addresses"]
        guard let endpoint = URL.endpoint(apiURL, pathComponents: components) else {
            return Completable.error(NetworkError.default)
        }
        
        let request = NetworkRequest(
            endpoint: endpoint,
            method: .post,
            body: try? JSONEncoder().encode(payload),
            authenticated: true,
            contentType: .json
        )
        return communicatorAPI.perform(request: request, responseType: EmptyNetworkResponse.self)
    }
    
    func linkToExistingExchangeUser(linkID: LinkID) -> Completable {
        let payload = ["linkId": linkID]
        guard let apiURL = URL(string: BlockchainAPI.shared.retailCoreUrl) else {
            return Completable.error(NetworkError.default)
        }
        let components = ["users", "link-account", "existing"]
        guard let endpoint = URL.endpoint(apiURL, pathComponents: components) else {
            return Completable.error(NetworkError.default)
        }
        
        let request = NetworkRequest(
            endpoint: endpoint,
            method: .put,
            body: try? JSONEncoder().encode(payload),
            authenticated: true,
            contentType: .json
        )
        return communicatorAPI.perform(request: request, responseType: EmptyNetworkResponse.self)
    }
    
    func fetchLinkIDPayload() -> Single<Dictionary<String, String>> {
        guard let apiURL = URL(string: BlockchainAPI.shared.retailCoreUrl) else {
            return Single.error(NetworkError.default)
        }
        let components = ["users", "link-account", "create", "start"]
        guard let endpoint = URL.endpoint(apiURL, pathComponents: components) else {
            return Single.error(NetworkError.default)
        }
        
        let request = NetworkRequest(
            endpoint: endpoint,
            method: .put,
            body: nil,
            authenticated: true,
            contentType: .json
        )
        
        return communicatorAPI.perform(request: request)
    }
    
    private func existingUserLinkIdentifier() -> Maybe<LinkID> {
        if let identifier = appSettings.exchangeLinkIdentifier {
            return Maybe.just(identifier)
        } else {
            return Maybe.empty()
        }
    }
}
