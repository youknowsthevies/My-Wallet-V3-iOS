//
//  CardClient.swift
//  PlatformKit
//
//  Created by Daniel Huri on 06/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import NetworkKit

public typealias CardClientAPI = CardListClientAPI &
                                 CardChargeClientAPI &
                                 CardDeletionClientAPI &
                                 CardActivationClientAPI &
                                 CardDetailClientAPI &
                                 CardAdditionClientAPI

public final class CardClient: CardClientAPI {
    
    // MARK: - Types
    
    private enum Parameter {
        static let currency = "currency"
    }
        
    private enum Path {
        static let card = [ "payments", "cards" ]
        
        static func activateCard(with id: String) -> [String] { Path.card + [ id, "activate" ] } 
    }
    
    // MARK: - Properties
    
    private let requestBuilder: RequestBuilder
    private let communicator: NetworkCommunicatorAPI

    // MARK: - Setup
    
    public init(dependencies: Network.Dependencies = .retail) {
        self.communicator = dependencies.communicator
        self.requestBuilder = RequestBuilder(networkConfig: dependencies.blockchainAPIConfig)
    }
    
    // MARK: - CardListClientAPI
    
    /// Streams a list of available cards
    /// - Parameter token: Session token
    /// - Returns: A Single with `CardPayload` array
    public func cardList(by token: String) -> Single<[CardPayload]> {
        let path = Path.card
        let headers = [HttpHeaderField.authorization: token]
        let request = requestBuilder.get(
            path: path,
            headers: headers
        )!
        return communicator.perform(request: request)
    }
    
    // MARK: - CardDetailClientAPI
        
    public func getCard(by id: String, token: String) -> Single<CardPayload> {
        let path = Path.card + [id]
        let headers = [HttpHeaderField.authorization: token]
        let request = requestBuilder.get(
            path: path,
            headers: headers
        )!
        return communicator.perform(request: request)
    }
    
    // MARK: - CardDeletionClientAPI

    public func deleteCard(by id: String, token: String) -> Completable {
        let path = Path.card + [id]
        let headers = [HttpHeaderField.authorization: token]
        let request = requestBuilder.delete(
            path: path,
            headers: headers
        )!
        return communicator.perform(request: request)
    }
    
    // MARK: - CardChargeClientAPI
    
    public func chargeCard(by id: String, token: String) -> Completable {
        let path = Path.card + [id, "charge"]
        let headers = [HttpHeaderField.authorization: token]
        let request = requestBuilder.post(
            path: path,
            headers: headers
        )!
        return communicator.perform(request: request)
    }
    
    // MARK: - CardAdditionClientAPI
    
    public func add(for currency: String,
                    billingAddress: CardPayload.BillingAddress,
                    token: String) -> Single<CardPayload> {
        struct RequestPayload: Encodable {
            let currency: String
            let address: CardPayload.BillingAddress
        }
        
        let payload = RequestPayload(
            currency: currency,
            address: billingAddress
        )
        
        let path = Path.card
        let headers = [HttpHeaderField.authorization: token]
        let request = requestBuilder.post(
            path: path,
            body: try? payload.encode(),
            headers: headers
        )!
        return communicator.perform(request: request)
    }
    
    // MARK: - CardActivationClientAPI
    
    /// EveryPay Only (Other provider would need different methods)
    /// Attempt to register the card method with the partner.
    /// Successful response should have card object and status should move to ACTIVE.
    /// - Parameters:
    ///   - id: ID of the card
    ///   - url: Everypay only - URL to return to after card verified
    ///   - token: Session token
    /// - Returns: The card details
    public func activateCard(by id: String,
                             url: String,
                             token: String) -> Single<ActivateCardResponse.Partner> {
        
        struct Attributes: Encodable {
            struct EveryPay: Encodable {
                let customerUrl: String
            }
            private let everypay: EveryPay?
            
            init(everypay: EveryPay) {
                self.everypay = everypay
            }
        }
        let path = Path.activateCard(with: id)
        let headers = [HttpHeaderField.authorization: token]
        let payload = Attributes(everypay: .init(customerUrl: url))
        
        let request = requestBuilder.post(
            path: path,
            body: try? payload.encode(),
            headers: headers
        )!
        return communicator
            .perform(request: request)
            .map { (response: ActivateCardResponse) in
                return response.partner
            }
    }
}
