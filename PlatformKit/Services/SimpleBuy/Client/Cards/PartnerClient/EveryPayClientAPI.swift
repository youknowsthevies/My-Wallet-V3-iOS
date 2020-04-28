//
//  EveryPayClientAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 16/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import NetworkKit

public protocol EveryPayClientAPI: class {
    func send(cardDetails: CardPartnerPayload.EveryPay.SendCardDetailsRequest.CardDetails,
              apiUserName: String,
              token: String) -> Single<CardPartnerPayload.EveryPay.CardDetailsResponse>
}
