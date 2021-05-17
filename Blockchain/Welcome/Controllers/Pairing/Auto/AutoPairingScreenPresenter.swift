// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

struct PairingCodeQRCodeTextViewModel: QRCodeScannerTextViewModel {
    let loadingText: String? = LocalizationConstants.parsingPairingCode
    let headerText: String = LocalizationConstants.scanPairingCode
}

/// A presenter for auto pairing screen
final class AutoPairingScreenPresenter {

    // MARK: - Types

    /// Actions which can take place if the scan fails
    enum FallbackAction {

        /// Stop scanning
        case stop

        /// Retry to scan pairing code
        case retry

        /// Cancel the scan
        case cancel
    }

    private typealias LocalizedString = LocalizationConstants.Onboarding.AutoPairingScreen

    // MARK: - Properties

    let navBarStyle = Screen.Style.Bar.lightContent()
    let titleStyle = Screen.Style.TitleView.text(value: LocalizedString.title)

    let scannerBuilder: QRCodeScannerViewControllerBuilder<PairingDataQRCodeParser>

    /// Streams a fallback action that should take place in case of failure
    var fallbackAction: Signal<FallbackAction> {
        fallbackActionRelay.asSignal()
    }

    private let fallbackActionRelay = PublishRelay<FallbackAction>()
    private let loadingViewPresenter: LoadingViewPresenting
    private let alertPresenter: AlertViewPresenter
    private let interactor: AutoPairingScreenInteractor

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(interactor: AutoPairingScreenInteractor = AutoPairingScreenInteractor(),
         alertPresenter: AlertViewPresenter = .shared,
         loadingViewPresenter: LoadingViewPresenting = resolve()) {
        self.interactor = interactor
        self.loadingViewPresenter = loadingViewPresenter
        self.alertPresenter = alertPresenter
        scannerBuilder = QRCodeScannerViewControllerBuilder(
            parser: interactor.parser,
            textViewModel: PairingCodeQRCodeTextViewModel(),
            completed: interactor.handlePairingCodeResult
        )
        .with(loadingViewPresenter: loadingViewPresenter, style: .circle)
        .with(presentationType: .child)

        interactor.error
            .bind { [weak self] _ in
                self?.fallbackActionRelay.accept(.stop)
                self?.showErrorAlert()
            }
            .disposed(by: disposeBag)
    }

    private func showErrorAlert() {
        loadingViewPresenter.hide()
        let tryAgain = UIAlertAction(
            title: LocalizedString.ErrorAlert.scanAgain,
            style: .default) { [unowned self] _ in
                self.fallbackActionRelay.accept(.retry)
            }
        let manualPairing = UIAlertAction(
            title: LocalizedString.ErrorAlert.manualPairing,
            style: .cancel) { [unowned self] _ in
                self.fallbackActionRelay.accept(.cancel)
            }
        alertPresenter.standardNotify(
            title: LocalizedString.ErrorAlert.title,
            message: LocalizedString.ErrorAlert.message,
            actions: [tryAgain, manualPairing]
        )
    }
}
