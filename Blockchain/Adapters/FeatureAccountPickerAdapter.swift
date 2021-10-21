// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAccountPickerUI
import Foundation
import PlatformUIKit
import RxCocoa
import RxSwift
import SwiftUI

class FeatureAccountPickerControllableAdapter: BaseScreenViewController {

    // MARK: - Private Properties

    fileprivate var disposeBag = DisposeBag()
    var shouldOverrideNavigationEffects: Bool = false

    fileprivate let modelSelectedRelay = PublishRelay<AccountPickerCellItem>()
    fileprivate let backButtonRelay = PublishRelay<Void>()
    fileprivate let closeButtonRelay = PublishRelay<Void>()
    fileprivate let sections = PassthroughSubject<[AccountPickerRow], Never>()
    fileprivate let header = PassthroughSubject<Header, Error>()

    fileprivate lazy var environment = AccountPickerEnvironment(
        rowSelected: { [unowned self] identifier in
            let viewModel = self.models.lazy.flatMap(\.items).first { item in
                item.identity == identifier
            }

            if let viewModel = viewModel {
                self.modelSelectedRelay.accept(viewModel)
            }
        },
        backButtonTapped: { [unowned self] in self.backButtonRelay.accept(()) },
        closeButtonTapped: { [unowned self] in self.closeButtonRelay.accept(()) },
        sections: { [unowned self] in self.sections.eraseToAnyPublisher() },
        updateSingleAccount: { [unowned self] account in
            guard case .singleAccount(let presenter) = self.presenter(for: account.id) else {
                return nil
            }

            return presenter.assetBalanceViewPresenter.state
                .asPublisher()
                .map { value in
                    var account = account
                    switch value {
                    case .loading:
                        account.fiatBalance = .loading
                        account.cryptoBalance = .loading
                    case .loaded(let balance):
                        account.fiatBalance = .loaded(next: balance.primaryBalance.text)
                        account.cryptoBalance = .loaded(next: balance.secondaryBalance.text)
                    }
                    return account
                }
                .eraseToAnyPublisher()
        },
        updateAccountGroup: { [unowned self] group in
            guard case .accountGroup(let presenter) = self.presenter(for: group.id) else {
                return nil
            }

            return presenter.walletBalanceViewPresenter.state
                .asPublisher()
                .map { value in
                    var group = group
                    switch value {
                    case .loading:
                        group.fiatBalance = .loading
                        group.currencyCode = .loading
                    case .loaded(let balance):
                        group.fiatBalance = .loaded(next: balance.fiatBalance.text)
                        group.currencyCode = .loaded(next: balance.currencyCode.text)
                    }
                    return group
                }
                .eraseToAnyPublisher()
        },
        header: { [header] in header.eraseToAnyPublisher() }
    )

    fileprivate var models: [AccountPickerSectionViewModel] = []

    // MARK: - Lifecycle

    init() {
        super.init(nibName: nil, bundle: nil)

        let child = UIHostingController(
            rootView: AccountPickerView(
                environment: environment,
                badgeView: { [unowned self] identity in
                    self.badgeView(for: identity)
                },
                iconView: { [unowned self] identity in
                    self.iconView(for: identity)
                },
                multiBadgeView: { [unowned self] identity in
                    self.multiBadgeView(for: identity)
                }
            )
        )
        addChild(child)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        children.forEach { child in
            view.addSubview(child.view)
            child.view.fillSuperview(usesSafeAreaLayoutGuide: true)
            child.didMove(toParent: self)
        }
    }

    // MARK: - Methods

    override func navigationBarLeadingButtonPressed() {
        guard shouldOverrideNavigationEffects else {
            super.navigationBarLeadingButtonPressed()
            return
        }
        switch leadingButtonStyle {
        case .close:
            closeButtonRelay.accept(())
        case .back:
            backButtonRelay.accept(())
        default:
            super.navigationBarLeadingButtonPressed()
        }
    }

    override func navigationBarTrailingButtonPressed() {
        guard shouldOverrideNavigationEffects else {
            super.navigationBarTrailingButtonPressed()
            return
        }
        switch trailingButtonStyle {
        case .close:
            closeButtonRelay.accept(())
        default:
            super.navigationBarLeadingButtonPressed()
        }
    }

    // MARK: - View Functions

    func presenter(for identity: AnyHashable) -> AccountPickerCellItem.Presenter? {
        models.lazy
            .flatMap(\.items)
            .first(where: { $0.identity == identity })?
            .presenter
    }

    func badgeView(for identity: AnyHashable) -> AnyView {
        switch presenter(for: identity) {
        case .singleAccount(let presenter):
            return AnyView(
                BadgeImageViewRepresentable(viewModel: presenter.badgeRelay.value, size: 32)
            )
        case .accountGroup(let presenter):
            return AnyView(
                BadgeImageViewRepresentable(viewModel: presenter.badgeImageViewModel, size: 32)
            )
        default:
            return AnyView(EmptyView())
        }
    }

    func iconView(for identity: AnyHashable) -> AnyView {
        switch presenter(for: identity) {
        case .singleAccount(let presenter):
            return AnyView(
                BadgeImageViewRepresentable(
                    viewModel: presenter.iconImageViewContentRelay.value,
                    size: 16
                )
            )
        default:
            return AnyView(EmptyView())
        }
    }

    func multiBadgeView(for identity: AnyHashable) -> AnyView {
        switch presenter(for: identity) {
        case .linkedBankAccount(let presenter):
            return AnyView(
                MultiBadgeViewRepresentable(viewModel: presenter.multiBadgeViewModel)
            )
        case .singleAccount(let presenter):
            return AnyView(
                MultiBadgeViewRepresentable(viewModel: .just(presenter.multiBadgeViewModel))
            )
        default:
            return AnyView(EmptyView())
        }
    }
}

extension FeatureAccountPickerControllableAdapter: AccountPickerViewControllable {

    func connect(state: Driver<AccountPickerPresenter.State>) -> Driver<AccountPickerInteractor.Effects> {
        disposeBag = DisposeBag()

        let stateWait: Driver<AccountPickerPresenter.State> =
            rx.viewDidLoad
                .asDriver()
                .flatMap { _ in
                    state
                }

        stateWait
            .map(\.navigationModel)
            .drive(weak: self) { (self, model) in
                self.titleViewStyle = model.titleViewStyle
                self.set(
                    barStyle: model.barStyle,
                    leadingButtonStyle: model.leadingButton,
                    trailingButtonStyle: model.trailingButton
                )
            }
            .disposed(by: disposeBag)

        stateWait.map(\.headerModel)
            .drive(weak: self) { (self, headerType) in
                let header: Header
                switch headerType {
                case .default(let model):
                    header = .normal(
                        title: model.title,
                        subtitle: model.subtitle,
                        image: model.imageContent.imageResource?.image,
                        tableTitle: model.tableTitle
                    )
                case .simple(let model):
                    header = .simple(subtitle: model.subtitle)
                case .none:
                    header = .none
                }
                self.header.send(header)
            }
            .disposed(by: disposeBag)

        stateWait.map(\.sections)
            .drive(weak: self) { (self, sectionModels) in
                self.models = sectionModels
                let sections = sectionModels
                    .flatMap(\.items)
                    .map { (item: AccountPickerCellItem) -> AccountPickerRow in
                        switch item.presenter {
                        case .emptyState(let labelContent):
                            return .label(
                                .init(
                                    id: item.identity,
                                    text: labelContent.text
                                )
                            )
                        case .button(let viewModel):
                            return .button(
                                .init(
                                    id: item.identity,
                                    text: viewModel.textRelay.value
                                )
                            )

                        case .linkedBankAccount(let presenter):
                            return .linkedBankAccount(
                                .init(
                                    id: item.identity,
                                    title: presenter.account.label,
                                    description: LocalizationConstants.accountEndingIn
                                        + " \(presenter.account.accountNumber)"
                                )
                            )

                        case .paymentMethodAccount(let presenter):
                            return .paymentMethodAccount(
                                .init(
                                    id: item.identity,
                                    title: presenter.account.label,
                                    description: presenter
                                        .account
                                        .paymentMethodType
                                        .balance
                                        .displayString,
                                    badgeView: presenter.account.logoResource.image,
                                    badgeBackground: Color(presenter.account.logoBackgroundColor)
                                )
                            )

                        case .accountGroup(let presenter):
                            return .accountGroup(
                                .init(
                                    id: item.identity,
                                    title: presenter.account.label,
                                    description: LocalizationConstants.Dashboard.Portfolio.totalBalance,
                                    fiatBalance: .loading,
                                    currencyCode: .loading
                                )
                            )

                        case .singleAccount(let presenter):
                            return .singleAccount(
                                .init(
                                    id: item.identity,
                                    title: presenter.account.label,
                                    description: presenter.account.currencyType.name,
                                    fiatBalance: .loading,
                                    cryptoBalance: .loading
                                )
                            )
                        }
                    }
                self.sections.send(sections)
            }
            .disposed(by: disposeBag)

        let modelSelected = modelSelectedRelay
            .compactMap(\.account)
            .map { AccountPickerInteractor.Effects.select($0) }
            .asDriver(onErrorJustReturn: .none)

        let backButtonEffect = backButtonRelay
            .map { AccountPickerInteractor.Effects.back }
            .asDriverCatchError()

        let closeButtonEffect = closeButtonRelay
            .map { AccountPickerInteractor.Effects.closed }
            .asDriverCatchError()

        return .merge(modelSelected, backButtonEffect, closeButtonEffect)
    }
}
