// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

protocol SendPAXInterface: class {
    func apply(updates: Set<SendMoniesPresentationUpdate>)
    func display(confirmation: BCConfirmPaymentViewModel)
    func displayQRCodeScanner()
}
