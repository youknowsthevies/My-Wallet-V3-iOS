//
//  ConfirmationPageDetailsPresenter.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 29/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

protocol ConfirmationPagePresentable: Presentable {
    var continueButtonTapped: Signal<Void> { get }
    func connect(action: Driver<ConfirmationPageInteractor.Action>) -> Driver<ConfirmationPageInteractor.Effects>
}

final class ConfirmationPageDetailsPresenter: DetailsScreenPresenterAPI, ConfirmationPagePresentable {
    // MARK: - Navigation Properties

    let reloadRelay = PublishRelay<Void>()
    let titleViewRelay = BehaviorRelay<Screen.Style.TitleView>(value: .none)
    let navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction
    let navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction

    var navigationBarAppearance: DetailsScreen.NavigationBarAppearance {
        .custom(
            leading: .back,
            trailing: .none,
            barStyle: .darkContent(ignoresStatusBar: false, background: .white)
        )
    }

    // MARK: - Actions
    var continueButtonTapped: Signal<Void> {
        continueButtonPressed.asSignal()
    }

    // MARK: - Screen Properties

    private(set) var buttons: [ButtonViewModel] = []
    private(set) var cells: [DetailsScreen.CellType] = []

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()
    private let navigationCloseRelay = PublishRelay<Void>()
    private let backButtonPressed = PublishRelay<Void>()
    private let cancelButtonPressed = PublishRelay<Void>()
    private let continueButtonPressed = PublishRelay<Void>()

    // MARK: - Injected

    private let analyticsRecorder: AnalyticsEventRecorderAPI

    init(analyticsRecorder: AnalyticsEventRecorderAPI = resolve()) {
        self.analyticsRecorder = analyticsRecorder

        navigationBarTrailingButtonAction = .default
        navigationBarLeadingButtonAction = .custom { [backButtonPressed] in
            backButtonPressed.accept(())
        }
    }

    func connect(action: Driver<ConfirmationPageInteractor.Action>) -> Driver<ConfirmationPageInteractor.Effects> {
        let details = action
            .distinctUntilChanged()
            .flatMap { (action) -> Driver<TransactionState> in
                switch action {
                case .empty:
                    return .empty()
                case .load(let data):
                    return .just(data)
                }
            }

        details
            .drive(weak: self, onNext: { (self, state) in
                self.setup(state: state)
            })
            .disposed(by: disposeBag)

        let closeTapped = cancelButtonPressed
            .map { ConfirmationPageInteractor.Effects.close }
            .asDriverCatchError()

        let backTapped = backButtonPressed
            .map { ConfirmationPageInteractor.Effects.back }
            .asDriverCatchError()

        return .merge(closeTapped, backTapped)
    }

    private func setup(state: TransactionState) {
        let contentReducer = ConfirmationPageContentReducer(state: state)

        titleViewRelay.accept(.text(value: contentReducer.title))

        buttons = [
            contentReducer.cancelButtonViewModel,
            contentReducer.continueButtonViewModel
        ]

        contentReducer.cancelButtonViewModel
            .tap
            .emit(to: cancelButtonPressed)
            .disposed(by: disposeBag)

        contentReducer.continueButtonViewModel
            .tap
            .emit(to: continueButtonPressed)
            .disposed(by: disposeBag)

        cells = contentReducer.cells

        reloadRelay.accept(())
    }
}
