//
//  CardAuthorizationScreenPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 21/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import Localization
import PlatformKit
import PlatformUIKit
import ToolKit

final class CardAuthorizationScreenPresenter: RibBridgePresenter {
    
    let title = LocalizationConstants.AuthorizeCardScreen.title
    
    var authorizationState: PartnerAuthorizationData.State {
        data.state
    }
    
    private let eventRecorder: AnalyticsEventRecording
    
    private let data: PartnerAuthorizationData
    private var hasRedirected = false
    
    private let interactor: CardAuthorizationScreenInteractor
    
    // MARK: - Setup
    
    init(interactor: CardAuthorizationScreenInteractor,
         data: PartnerAuthorizationData,
         eventRecorder: AnalyticsEventRecording) {
        self.eventRecorder = eventRecorder
        self.interactor = interactor
        self.data = data
        super.init(interactable: interactor)
    }
    
    func redirect() {
        /// Might get called multiple times from the `WKNavigationDelegate`
        guard !hasRedirected else { return }
        hasRedirected = true
        self.eventRecorder.record(event: AnalyticsEvents.SimpleBuy.sbThreeDSecureComplete)
        interactor.cardAuthorized(with: data.paymentMethodId)
    }
}

