//
//  WithdrawalConfirmationInteractor.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 02/11/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa
import RxSwift

final class WithdrawalConfirmationPresenter: RibBridgePresenter, PendingStatePresenterAPI {

    private typealias LocalizedString = LocalizationConstants.SimpleBuy.Checkout.PendingOrderScreen

    // MARK: - Properties
    var viewModel: Driver<PendingStateViewModel> = .empty()

    // MARK: - Private Properties
    private weak var routing: WithdrawalConfirmationRouting?
    private let interactor: WithdrawalConfirmationInteractor
    private let disposeBag = DisposeBag()

    init(interactor: WithdrawalConfirmationInteractor, routing: WithdrawalConfirmationRouting) {
        self.interactor = interactor
        self.routing = routing
        super.init(interactable: interactor)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let buttonModel = ButtonViewModel.primary(with: LocalizedString.button)
        buttonModel.tap
            .emit(weak: self) { (self, _) in
                self.routing?.confirmationRequested(to: .closeFlow)
            }
            .disposed(by: disposeBag)

        viewModel = Driver.deferred({ [interactor] () -> Driver<PendingStateViewModel> in
            guard let amount = interactor.amount, interactor.isSuccess || interactor.isLoading else {
                return .just(Self.errorViewModel(with: interactor.currencyType, buttonModel: buttonModel))
            }
            if interactor.isSuccess {
                return .just(Self.viewModel(with: amount, buttonModel: buttonModel))
            }
            return .just(Self.loadingViewModel(with: amount))
        })
    }

    // MARK: - View Model Providers

    private static func loadingViewModel(with amount: FiatValue) -> PendingStateViewModel {
        PendingStateViewModel(
            compositeStatusViewType:
                .composite(
                    .init(baseViewType: .text(amount.currency.symbol),
                          sideViewAttributes: .init(type: .loader, position: .rightCorner),
                          backgroundColor: .fiat,
                          cornerRadiusRatio: 0.2)
                ),
            title: "Withdrawing \(amount.toDisplayString(includeSymbol: true))",
            subtitle: "We’re completing your withdrawal now.")
    }

    private static func viewModel(with amount: FiatValue, buttonModel: ButtonViewModel) -> PendingStateViewModel {
        // TODO: Use localized strings here
        let amountTitle = amount.toDisplayString(includeSymbol: true)
        let subtitle = "Success! We're are withdrawing the cash from your GBP Wallet now. The funds should be in your bank in 1-3 business days."
        return PendingStateViewModel(compositeStatusViewType: .composite(
            .init(
                baseViewType: .text(amount.currencyType.symbol),
                sideViewAttributes: .init(type: .image(PendingStateViewModel.Image.success.name), position: .radiusDistanceFromCenter),
                backgroundColor: .fiat,
                cornerRadiusRatio: 0.2
            )
        ),
        title: "\(amountTitle) Withdrawal",
        subtitle: subtitle,
        button: buttonModel)
    }

    private static func errorViewModel(with currencyType: CurrencyType, buttonModel: ButtonViewModel) -> PendingStateViewModel {
        PendingStateViewModel(compositeStatusViewType: .composite(
            .init(
                baseViewType: .text(currencyType.symbol),
                sideViewAttributes: .init(type: .image(PendingStateViewModel.Image.circleError.name), position: .rightCorner),
                backgroundColor: .fiat,
                cornerRadiusRatio: 0.2
            )
        ),
        title: LocalizationConstants.ErrorScreen.title,
        subtitle: LocalizationConstants.ErrorScreen.subtitle,
        button: buttonModel)
    }
}

