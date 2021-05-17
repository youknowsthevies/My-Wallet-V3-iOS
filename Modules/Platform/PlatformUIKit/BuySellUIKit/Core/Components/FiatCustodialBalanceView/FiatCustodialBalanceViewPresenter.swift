// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxCocoa
import RxSwift

public final class FiatCustodialBalanceViewPresenter: Equatable {

    // MARK: - Types

    public enum PresentationStyle {
        case border
        case plain
    }

    public struct Descriptors {
        let currencyNameFont: UIFont
        let currencyNameFontColor: UIColor
        let currencyNameAccessibilityId: Accessibility
        let currencyCodeFont: UIFont
        let currencyCodeFontColor: UIColor
        let currencyCodeAccessibilityId: Accessibility
        let badgeImageAccessibilitySuffix: String
        let balanceViewDescriptors: FiatBalanceViewAsset.Value.Presentation.Descriptors
    }

    /// Emits tap events
    public var tap: Signal<Void> {
        tapRelay.asSignal()
    }

    let fiatBalanceViewPresenter: FiatBalanceViewPresenter

    /// The badge showing the currency symbol
    var badgeImageViewModel: Driver<BadgeImageViewModel> {
        badgeRelay.asDriver()
    }

    /// The name of the currency showed in the balance
    var currencyName: Driver<LabelContent> {
        currencyNameRelay.asDriver()
    }

    /// The currency code of the currency showed in the balance
    var currencyCode: Driver<LabelContent> {
        currencyCodeRelay.asDriver()
    }

    var identifier: String {
        interactor.identifier
    }

    var currencyType: CurrencyType {
        interactor.balance.base.currencyType
    }

    let tapRelay = PublishRelay<Void>()
    let respondsToTaps: Bool
    let presentationStyle: PresentationStyle

    private let badgeRelay = BehaviorRelay<BadgeImageViewModel>(value: .empty)
    private let currencyNameRelay = BehaviorRelay<LabelContent>(value: .empty)
    private let currencyCodeRelay = BehaviorRelay<LabelContent>(value: .empty)
    private let interactor: FiatCustodialBalanceViewInteractor
    private let disposeBag = DisposeBag()

    public init(interactor: FiatCustodialBalanceViewInteractor,
                descriptors: Descriptors,
                respondsToTaps: Bool,
                presentationStyle: PresentationStyle) {
        self.interactor = interactor
        self.respondsToTaps = respondsToTaps
        self.presentationStyle = presentationStyle
        fiatBalanceViewPresenter = FiatBalanceViewPresenter(
            interactor: interactor.balanceViewInteractor,
            descriptors: descriptors.balanceViewDescriptors
        )

        interactor
            .currency
            .map { $0.logoImageName }
            .map {
                .primary(
                    with: $0,
                    contentColor: .white,
                    backgroundColor: .fiat,
                    cornerRadius: .value(8.0),
                    accessibilityIdSuffix: descriptors.badgeImageAccessibilitySuffix
                )
            }
            .bindAndCatch(to: badgeRelay)
            .disposed(by: disposeBag)

        interactor
            .currency
            .map { $0.code }
            .map {
                .init(
                    text: $0,
                    font: descriptors.currencyCodeFont,
                    color: descriptors.currencyCodeFontColor,
                    accessibility: descriptors.currencyCodeAccessibilityId
                )
            }
            .bindAndCatch(to: currencyCodeRelay)
            .disposed(by: disposeBag)

        interactor
            .currency
            .map { $0.name }
            .map {
                .init(
                    text: $0,
                    font: descriptors.currencyNameFont,
                    color: descriptors.currencyNameFontColor,
                    accessibility: descriptors.currencyNameAccessibilityId
                )
            }
            .bindAndCatch(to: currencyNameRelay)
            .disposed(by: disposeBag)

    }
}

public extension FiatCustodialBalanceViewPresenter {
    static func ==(lhs: FiatCustodialBalanceViewPresenter, rhs: FiatCustodialBalanceViewPresenter) -> Bool {
        lhs.interactor.balance == rhs.interactor.balance
    }
}

public extension FiatCustodialBalanceViewPresenter.Descriptors {
    typealias Descriptors = FiatCustodialBalanceViewPresenter.Descriptors
    typealias DashboardAccessibility = Accessibility.Identifier.Dashboard.FiatCustodialCell

    static func dashboard(baseAccessibilitySuffix: String = "",
                          quoteAccessibilitySuffix: String = "") -> Descriptors {
        Descriptors(
            currencyNameFont: .main(.semibold, 20.0),
            currencyNameFontColor: .textFieldText,
            currencyNameAccessibilityId: .init(id: .value(DashboardAccessibility.currencyName)),
            currencyCodeFont: .main(.medium, 14.0),
            currencyCodeFontColor: .descriptionText,
            currencyCodeAccessibilityId: .init(id: .value(DashboardAccessibility.currencyCode)),
            badgeImageAccessibilitySuffix: DashboardAccessibility.currencyBadgeView,
            balanceViewDescriptors: .dashboard(
                baseAccessibilitySuffix: baseAccessibilitySuffix,
                quoteAccessibilitySuffix: quoteAccessibilitySuffix
            )
        )
    }

    static func paymentMethods(baseAccessibilitySuffix: String = "",
                               quoteAccessibilitySuffix: String = "") -> Descriptors {
        Descriptors(
            currencyNameFont: .main(.semibold, 16),
            currencyNameFontColor: .textFieldText,
            currencyNameAccessibilityId: .init(id: .value(DashboardAccessibility.currencyName)),
            currencyCodeFont: .main(.medium, 14),
            currencyCodeFontColor: .descriptionText,
            currencyCodeAccessibilityId: .init(id: .value(DashboardAccessibility.currencyCode)),
            badgeImageAccessibilitySuffix: DashboardAccessibility.currencyBadgeView,
            balanceViewDescriptors: .paymentMethods(
                baseAccessibilitySuffix: baseAccessibilitySuffix,
                quoteAccessibilitySuffix: quoteAccessibilitySuffix
            )
        )
    }
}
