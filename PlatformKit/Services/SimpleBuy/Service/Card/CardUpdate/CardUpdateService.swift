//
//  CardUpdateService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 06/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

public final class CardUpdateService: CardUpdateServiceAPI {
    
    // MARK: - Types
    
    public enum ServiceError: Error {
        case unknownPartner
    }
    
    // MARK: - Injected
    
    private let cardClient: CardClientAPI
    private let everyPayClient: EveryPayClientAPI
    private let dataRepository: DataRepositoryAPI
    private let authenticationService: NabuAuthenticationServiceAPI
    private let fiatCurrencyService: FiatCurrencySettingsServiceAPI
    
    // MARK: - Setup
    
    public init(dataRepository: DataRepositoryAPI,
                cardClient: CardClientAPI,
                everyPayClient: EveryPayClientAPI,
                fiatCurrencyService: FiatCurrencySettingsServiceAPI,
                authenticationService: NabuAuthenticationServiceAPI) {
        self.dataRepository = dataRepository
        self.cardClient = cardClient
        self.everyPayClient = everyPayClient
        self.authenticationService = authenticationService
        self.fiatCurrencyService = fiatCurrencyService
    }
    
    public func add(card: CardData) -> Single<PartnerAuthorizationData> {
        
        // Get the user email
        let email = dataRepository.userSingle
            .map { $0.email.address }
        
        return Single
            .zip(
                authenticationService.tokenString,
                fiatCurrencyService.fiatCurrency,
                email
            )
            .map { (token: $0.0, currency: $0.1, email: $0.2) }
            // 1. Add the card details via BE
            .flatMap(weak: self) { (self, payload) -> Single<(response: CardPayload, token: String)> in
                self.cardClient
                    .add(
                        for: payload.currency.code,
                        email: payload.email,
                        billingAddress: card.billingAddress.requestPayload,
                        token: payload.token
                    )
                    .map { response -> (response: CardPayload, token: String) in
                        return (response, payload.token)
                    }
            }
            // 2. Make sure the card partner is supported
            .map { payload -> (response: CardPayload, token: String) in
                guard payload.response.partner.isKnown else {
                    throw ServiceError.unknownPartner
                }
                return payload
            }
            // 3. Activate the card
            .flatMap(weak: self) { (self, payload) -> Single<(cardId: String, partner: ActivateCardResponse.Partner)> in
                self.cardClient.activateCard(
                    by: payload.response.identifier,
                    url: PartnerAuthorizationData.exitLink,
                    token: payload.token
                )
                .map {
                    (cardId: payload.response.identifier, partner: $0)
                }
            }
            // 4. Partner
            .flatMap(weak: self) { (self, payload) -> Single<PartnerAuthorizationData> in
                self
                    .add(
                        card: card,
                        via: payload.partner
                    )
                    .map {
                        PartnerAuthorizationData(
                            state: $0,
                            paymentMethodId: payload.cardId
                        )
                    }
            }
    }
    
    // MARK: - Partner Integration
    
    private func add(card: CardData,
                     via partner: ActivateCardResponse.Partner) -> Single<PartnerAuthorizationData.State> {
        switch partner {
        case .everypay(let data):
            return add(card: card, with: data)
        case .unknown:
            return .error(ServiceError.unknownPartner)
        }
    }
    
    /// Add via every pay
    private func add(card: CardData,
                     with everyPayData: ActivateCardResponse.Partner.EveryPayData) -> Single<PartnerAuthorizationData.State> {
        everyPayClient
            .send(
                cardDetails: card.everyPayCardDetails,
                apiUserName: everyPayData.apiUsername,
                token: everyPayData.mobileToken
            )
            .map { response -> PartnerAuthorizationData.State in
                switch response.status {
                case .waitingFor3DResponse:
                    let url = URL(string: everyPayData.paymentLink)!
                    return .required(.init(paymentLink: url))
                case .failed, .authorized, .settled, .waitingForBav:
                    return .none
                }
            }
    }
}
