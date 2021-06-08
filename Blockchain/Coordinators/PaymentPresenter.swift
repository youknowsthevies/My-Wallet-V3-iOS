// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxSwift

/// Subscribes to payments and presents a confirmation to the user upon receiving them
class PaymentPresenter {

    // MARK: - Properties

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(walletManager: WalletManager = .shared) {
        walletManager.paymentReceived
            .observeOn(MainScheduler.instance)
            .bind { [weak self] payment in
                self?.displayAlert(with: payment)
            }
            .disposed(by: disposeBag)
    }

    private func displayAlert(with payment: ReceivedPaymentDetails) {
        let button = AlertAction(style: .confirm(LocalizationConstants.close))
        let title = "\(payment.asset.name) \(LocalizationConstants.PaymentReceivedAlert.titleSuffix)"
        let localImage = payment.asset.logoResource.localImage
        let alert = AlertModel(headline: title,
                               body: payment.amount,
                               actions: [button],
                               image: localImage,
                               style: .sheet)
        let alertView = AlertView.make(with: alert, completion: nil)
        alertView.show()
    }
}
