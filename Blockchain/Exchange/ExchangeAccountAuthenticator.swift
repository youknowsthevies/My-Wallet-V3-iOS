// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import NetworkKit
import PlatformKit
import RxSwift
import ToolKit

protocol ExchangeAccountAuthenticatorAPI {
    typealias LinkID = String
    var exchangeLinkID: Single<LinkID> { get }
    var exchangeURL: Single<URL> { get }
    var nabuUser: Observable<NabuUser> { get }
    func linkToExistingExchangeUser(linkID: LinkID) -> Completable
}

class ExchangeAccountAuthenticator: ExchangeAccountAuthenticatorAPI {
    
    private let blockchainRepository: BlockchainDataRepository
    private let client: ExchangeClientAPI
    private let campaignComposer: CampaignComposer
    
    init(blockchainRepository: BlockchainDataRepository = BlockchainDataRepository.shared,
         campaignComposer: CampaignComposer = CampaignComposer(),
         client: ExchangeClientAPI = resolve()) {
        self.blockchainRepository = blockchainRepository
        self.campaignComposer = campaignComposer
        self.client = client
    }
    
    var exchangeLinkID: Single<LinkID> {
        self.client.linkID
    }
    
    var exchangeURL: Single<URL> {
        Single
            .zip(blockchainRepository.fetchNabuUser(), exchangeLinkID)
            .flatMap(weak: self, { (self, payload) -> Single<URL> in
                let user = payload.0
                let linkID = payload.1
                
                let email = self.percentEscapeString(user.email.address)
                guard let apiURL = URL(string: BlockchainAPI.shared.exchangeURL) else {
                    return Single.error(ExchangeLinkingAPIError.unknown)
                }
                
                let pathComponents = ["trade", "link", linkID]
                var queryParams = Dictionary(
                    uniqueKeysWithValues: self.campaignComposer.generalQueryValuePairs
                        .map { ($0.rawValue, $1.rawValue) }
                )
                queryParams += ["email": email]
                
                guard let endpoint = URL.endpoint(apiURL, pathComponents: pathComponents, queryParameters: queryParams) else {
                    return Single.error(ExchangeLinkingAPIError.unknown)
                }
                
                return Single.just(endpoint)
            })
    }
    
    var nabuUser: Observable<NabuUser> {
        Observable<Int>.interval(
            3,
            scheduler: MainScheduler.asyncInstance
        ).flatMap(weak: self, selector: { (self, _) -> Observable<NabuUser> in
            self.blockchainRepository.fetchNabuUser().asObservable()
        })
    }
        
    func linkToExistingExchangeUser(linkID: LinkID) -> Completable {
        self.client.linkToExistingExchangeUser(linkID: linkID)
    }
    
    private func percentEscapeString(_ stringToEscape: String) -> String {
        let characterSet = NSMutableCharacterSet.alphanumeric()
        characterSet.addCharacters(in: "-._* ")
        return stringToEscape
            .addingPercentEncoding(withAllowedCharacters: characterSet as CharacterSet)?
            .replacingOccurrences(of: " ", with: "+", options: [], range: nil) ?? stringToEscape
    }
}
