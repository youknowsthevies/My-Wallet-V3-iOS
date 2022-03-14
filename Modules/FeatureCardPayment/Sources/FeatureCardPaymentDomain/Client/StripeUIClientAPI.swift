// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public protocol StripeUIClientAPI {
    func confirmPayment(
        _ data: PartnerAuthorizationData,
        with presenter: CardAuthorizationScreenPresenterAPI
    )
}
