// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension StateService.States: CustomDebugStringConvertible {

    var debugDescription: String {
        "current: \(current.debugDescription), previous: \(previous.map(\.debugDescription))"
    }
}

extension StateService.State: CustomDebugStringConvertible {

    public var debugDescription: String {
        let suffix: String
        switch self {
        case .intro:
            suffix = "intro"
        case .selectFiat:
            suffix = "select-fiat"
        case .showURL:
            suffix = "show-url"
        case .unsupportedFiat:
            suffix = "unsupported-fiat"
        case .buy:
            suffix = "enter-amount-to-buy"
        case .changeFiat:
            suffix = "change-fiat"
        case .paymentMethods:
            suffix = "payment-methods"
        case .addCard, .linkCard:
            suffix = "add-card"
        case .kycBeforeCheckout:
            suffix = "kyc-before-checkout"
        case .kyc:
            suffix = "kyc"
        case .pendingKycApproval:
            suffix = "pending-kyc-approval"
        case .ineligible:
            suffix = "ineligible-for-buy"
        case .checkout:
            suffix = "checkout"
        case .bankTransferDetails:
            suffix = "bank-transfer-details"
        case .fundsTransferDetails:
            suffix = "funds-transfer-details"
        case .authorizeCard:
            suffix = "authorize-card"
        case .authorizeOpenBanking:
            suffix = "authorize-open-banking"
        case .transferCancellation:
            suffix = "order-cancellation"
        case .pendingOrderDetails:
            suffix = "pending-order-details"
        case .pendingOrderCompleted:
            suffix = "pending-order-completed"
        case .linkBank:
            suffix = "link-bank"
        case .inactive:
            suffix = "inactive"
        }
        return "buy-state: \(suffix)"
    }
}
