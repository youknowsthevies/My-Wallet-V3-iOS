// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift

final class PortfolioEmptyStatePresenter {
    typealias LocalizedString = LocalizationConstants.Dashboard.Portfolio.EmptyState

    let title = LabelContent(
        text: "Welcome to Blockchain.com!",
        font: .main(.semibold, 20),
        color: .darkTitleText,
        alignment: .center
    )
    let subtitle = LabelContent(
        text: "All your crypto balances will show up here once you buy or receive.",
        font: .main(.medium, 14),
        color: .darkTitleText,
        alignment: .center
    )
    let cta = ButtonViewModel.primary(with: "Buy Crypto")
    let didTapReceive: PublishRelay<Void> = .init()
    let didTapDeposit: PublishRelay<Void> = .init()

    private let interactor: PortfolioEmptyStateInteractor
    private let disposeBag: DisposeBag = .init()

    init(interactor: PortfolioEmptyStateInteractor = .init()) {
        self.interactor = interactor

        didTapReceive
            .bind { [interactor] _ in
                interactor.switchTabToReceive()
            }
            .disposed(by: disposeBag)

        cta.tap
            .emit(onNext: { [interactor] _ in
                interactor.handleBuy()
            })
            .disposed(by: disposeBag)

        didTapDeposit
            .bind { [interactor] _ in
                interactor.handleDeposit()
            }
            .disposed(by: disposeBag)
    }
}
