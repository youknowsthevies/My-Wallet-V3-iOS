//
//  SendPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Foundation
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

struct AddressQRCodeTextViewModel: QRCodeScannerTextViewModel {
    let loadingText: String? = nil
    let headerText: String = LocalizationConstants.scanQRCode
}

/// A class the is responsible for the send flow
final class SendPresenter {
    
    // MARK: - Types
    
    /// Update for the navigation right button
    struct NavigationRightButtonUpdate {
        
        /// The type of the indicator
        enum Indicator {
            
            /// Error indication with state
            case error(SendInputState.StateError)
            
            /// QR code indication
            case qrCode
            
            /// Processing indication (something is currently being calculated)
            case processing
            
            /// The button type
            var button: NavigationCTAType {
                switch self {
                case .error:
                    return .error
                case .qrCode:
                    return .qrCode
                case .processing:
                    return .activityIndicator
                }
            }
            
            /// Returns `true` if `self` represents an error
            var isError: Bool {
                switch self {
                case .error:
                    return true
                default:
                    return false
                }
            }
        }
        
        let color: UIColor
        let indicator: Indicator
        
        init(state: SendInputState) {
            switch state {
            case .calculating:
                indicator = .processing
                color = .white
            case .empty, .valid:
                indicator = .qrCode
                color = .white
            case .invalid(let error):
                indicator = .error(error)
                color = .pending
            }
        }
    }
    
    // TODO: Moving to support multiple assets, this info should be a dynamically determined
    struct TableViewDataSource {
        struct CellIndex {
            static let source = 0
            static let destination = 1
            static let amount = 2
            static let fee = 3
        }
        static let cellCount = 4
    }
    
    // MARK: - Exposed Properties
    
    /// Returns the asset
    var asset: CryptoCurrency {
        interactor.asset
    }
    
    /// Streams `true` when the continue button should be enabled
    var isContinueButtonEnabled: Driver<Bool> {
        interactor.inputState
            .map { $0.isValid }
            .asDriver(onErrorJustReturn: false)
    }
    
    /// Signals for error in case there is any
    var error: Signal<SendInputState.StateError> {
        errorRelay.asSignal()
    }
    
    /// Signals for alert notification
    var alert: Signal<AlertViewContent> {
        alertRelay.asSignal()
    }
    
    /// Streams the right button type
    var navigationRightButton: Observable<NavigationRightButtonUpdate> {
        navigationRightButtonRelay
            .observeOn(MainScheduler.instance)
    }
    
    // TODO: Change this once we make the navigation mechanism Rx friendly
    var navigationRightButtonValue: NavigationRightButtonUpdate {
        navigationRightButtonRelay.value
    }
    
    // MARK: - Sub-Presenters
    
    let sourcePresenter: SendSourceAccountCellPresenter
    let destinationPresenter: SendDestinationAccountCellPresenter
    let amountPresenter: SendAmountCellPresenter
    let spendableBalancePresenter: SendSpendableBalanceViewPresenter
    let feePresenter: SendFeeCellPresenter
    
    // MARK: - Services
    
    private unowned let router: SendRouter
    private let loader: LoadingViewPresenting
    private let interactor: SendInteracting
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    
    // MARK: - Accessors
    
    private let alertRelay = PublishRelay<AlertViewContent>()
    private let errorRelay = PublishRelay<SendInputState.StateError>()
    private let navigationRightButtonRelay = BehaviorRelay<NavigationRightButtonUpdate>(value: .init(state: .empty))
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(router: SendRouter,
         loader: LoadingViewPresenting = resolve(),
         interactor: SendInteracting,
         analyticsRecorder: AnalyticsEventRecorderAPI = resolve()) {
        self.router = router
        self.loader = loader
        self.interactor = interactor
        self.analyticsRecorder = analyticsRecorder
        sourcePresenter = SendSourceAccountCellPresenter(
            interactor: interactor.sourceInteractor
        )
        destinationPresenter = SendDestinationAccountCellPresenter(
            interactor: interactor.destinationInteractor
        )
        let spendableBalancePresenter = SendSpendableBalanceViewPresenter(
            asset: interactor.asset,
            interactor: interactor.spendableBalanceInteractor
        )
        amountPresenter = SendAmountCellPresenter(
            spendableBalancePresenter: spendableBalancePresenter,
            interactor: interactor.amountInteractor
        )
        feePresenter = SendFeeCellPresenter(interactor: interactor.feeInteractor)
        self.spendableBalancePresenter = spendableBalancePresenter
        
        interactor.inputState
            .map { NavigationRightButtonUpdate(state: $0) }
            .bindAndCatch(to: navigationRightButtonRelay)
            .disposed(by: disposeBag)
        
        destinationPresenter.twoFAConfigurationAlertSignal
            .emit(to: alertRelay)
            .disposed(by: disposeBag)
        
        navigationRightButton
            .filter { $0.indicator.isError }
            .map { _ in AnalyticsEvents.Send.sendFormErrorAppear(asset: interactor.asset) }
            .bindAndCatch(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)
    }
    
    /// Clean the states of all the sub-presenters & interactor
    func clean() {
        interactor.clean()
        destinationPresenter.clean()
        amountPresenter.clean()
    }
    
    // MARK: - Private

    /// Scan a QR code. This method builds the QR code controller builder and interacts with
    /// the router in order to present the view controller
    func scanQRCode() {
        guard let scanner = QRCodeScanner() else { return }
        
        let parser = AddressQRCodeParser(assetType: asset)
        let textViewModel = AddressQRCodeTextViewModel()
        
        let qrScannerViewModel = QRCodeScannerViewModel(
            parser: parser,
            additionalParsingOptions: .strict,
            textViewModel: textViewModel,
            scanner: scanner,
            completed: { [weak self] result in
                guard let self = self else { return }
                guard case .success(let assetURL) = result else {
                    return
                }
                self.destinationPresenter.addressFieldEdited(input: assetURL.payload.address, shouldPublish: true)
                if let amount = assetURL.payload.amount {
                    self.amountPresenter.cryptoFieldEdited(rawValue: amount, shouldPublish: true)
                }
            })
        let builder = QRCodeScannerViewControllerBuilder(viewModel: qrScannerViewModel)!
        router.presentQRScan(using: builder)
    }
    
    /// Prepares the view and interaction layer for sending the transaction.
    /// Getting called when `Continue` button is tapped
    /// **MUST** be called before sending a transaction.
    func prepareForSending() -> Single<BCConfirmPaymentViewModel> {
        let confirmationData = Observable
            .zip(
                sourcePresenter.account.asObservable(),
                destinationPresenter.finalDisplayAddress,
                amountPresenter.totalCrypto,
                amountPresenter.totalFiat,
                feePresenter.fee.asObservable()
            )
            .take(1) // Take the first, drop the rest.
            .asSingle()
        
        return interactor.prepareForSending()
            .recordOnResult(
                successEvent: AnalyticsEvents.Send.sendFormConfirmSuccess(asset: asset),
                errorEvent: AnalyticsEvents.Send.sendFormConfirmFailure(asset: asset),
                using: analyticsRecorder
            )
            .flatMap { confirmationData }
            .map { (source, destination, totalCrypto, totalFiat, fee) -> BCConfirmPaymentViewModel in
                BCConfirmPaymentViewModel(
                    from: source,
                    destinationDisplayAddress: destination,
                    destinationRawAddress: "", // TODO: Remove `destinationRawAddress`
                    totalAmountText: totalCrypto,
                    fiatTotalAmountText: totalFiat,
                    cryptoWithFiatAmountText: "\(totalCrypto) \(totalFiat)",
                    amountWithFiatFeeText: fee,
                    buttonTitle: LocalizationConstants.SendAsset.send,
                    showDescription: false,
                    surgeIsOccurring: false,
                    showsFeeInformationButton: false,
                    noteText: nil,
                    warningText: nil,
                    descriptionTitle: nil
                    )!
            }
            .observeOn(MainScheduler.instance)
    }
}

// MARK: - Navigation & CTA

extension SendPresenter {
    
    /// Right button CTA
    func navigationRightButtonTapped() {
        switch navigationRightButtonRelay.value.indicator {
        case .error(let error):
            recordErrorClick()
            errorRelay.accept(error)
        case .qrCode:
            recordQrButtonClick()
            scanQRCode()
        case .processing:
            break
        }
    }

    /// CTA for the send button. Once invoked, the transaction will be initiated
    func sendButtonTapped() -> Single<Void> {
        interactor.send()
            .record(
                subscribeEvent: AnalyticsEvents.Send.sendSummaryConfirmClick(asset: asset),
                successEvent: AnalyticsEvents.Send.sendSummaryConfirmSuccess(asset: asset),
                errorEvent: AnalyticsEvents.Send.sendSummaryConfirmFailure(asset: asset),
                using: analyticsRecorder
            )
            .handleLoaderForLifecycle(loader: loader, text: LocalizationConstants.loading)
            .observeOn(MainScheduler.instance)
    }
}

// MARK: - Hashable (identifiable by the asset)

extension SendPresenter: Hashable {
    static func == (lhs: SendPresenter, rhs: SendPresenter) -> Bool {
        lhs.asset == rhs.asset
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(asset)
    }
}

// MARK: - Analytics

extension SendPresenter {
    
    func recordShowErrorAlert() {
        analyticsRecorder.record(
            event: AnalyticsEvents.Send.sendFormShowErrorAlert(asset: asset)
        )
    }
    
    func recordContinueClick() {
        analyticsRecorder.record(
            event: AnalyticsEvents.Send.sendFormConfirmClick(asset: asset)
        )
    }
    
    private func recordQrButtonClick() {
        analyticsRecorder.record(
            event: AnalyticsEvents.Send.sendFormQrButtonClick(asset: asset)
        )
    }
    
    private func recordErrorClick() {
        analyticsRecorder.record(
            event: AnalyticsEvents.Send.sendFormErrorClick(asset: asset)
        )
    }
}
