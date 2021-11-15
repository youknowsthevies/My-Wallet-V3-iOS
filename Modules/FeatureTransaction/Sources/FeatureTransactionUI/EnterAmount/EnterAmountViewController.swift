// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureWithdrawalLocksUI
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import SwiftUI
import UIKit

final class EnterAmountViewController: BaseScreenViewController,
    EnterAmountViewControllable,
    EnterAmountPagePresentable
{

    // MARK: - Types

    private enum Constant {
        enum SuperCompact {
            static let digitPadHeight: CGFloat = 216
            static let continueButtonViewBottomOffset: CGFloat = 16
            static let topSelectionViewHeight: CGFloat = 48
            static let bottomAuxiliaryViewOffset: CGFloat = 8
        }

        enum Standard {
            static let topSelectionViewHeight: CGFloat = 78
            static let bottomSelectionViewHeight: CGFloat = 78
        }
    }

    // MARK: - Auxiliary Views

    private let topAuxiliaryViewContainer = UIView()
    private let bottomAuxiliaryViewContainer = UIView()

    private var topAuxiliaryViewHeightConstraint: NSLayoutConstraint!
    private var bottomAuxiliaryViewHeightConstraint: NSLayoutConstraint!

    private var topAuxiliaryViewController: UIViewController?
    private var bottomAuxiliaryViewController: UIViewController?

    private let topAuxiliaryItemSeparatorView = TitledSeparatorView()
    private let bottomAuxiliaryItemSeparatorView = TitledSeparatorView()

    // MARK: - Main CTA

    private let continueButtonView = ButtonView()
    internal let continueButtonTapped: Signal<Void>

    private var ctaContainerView = UIView()
    private var ctaTopConstraint: NSLayoutConstraint!

    private var errorRecoveryCTAModel: ErrorRecoveryCTAModel
    private let errorRecoveryViewController: UIViewController

    // MARK: - Other Properties

    private let bottomSheetPresenting = BottomSheetPresenting(ignoresBackgroundTouches: true)
    private let amountViewable: AmountViewable
    private let digitPadView = DigitPadView()
    private var digitPadHeightConstraint: NSLayoutConstraint!

    private let closeTriggerred = PublishSubject<Void>()
    private let backTriggered = PublishSubject<Void>()

    // MARK: - Injected

    private let displayBundle: DisplayBundle
    private let devicePresenterType: DevicePresenter.DeviceType
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(
        displayBundle: DisplayBundle,
        devicePresenterType: DevicePresenter.DeviceType = DevicePresenter.type,
        digitPadViewModel: DigitPadViewModel,
        continueButtonViewModel: ButtonViewModel,
        recoverFromInputError: @escaping () -> Void,
        amountViewProvider: AmountViewable
    ) {
        self.displayBundle = displayBundle
        self.devicePresenterType = devicePresenterType
        amountViewable = amountViewProvider
        continueButtonTapped = continueButtonViewModel.tap

        let errorRecoveryCTAModel = ErrorRecoveryCTAModel(
            buttonTitle: "", // initial state shows no error, and the button is hidden, so this is OK
            action: recoverFromInputError
        )
        self.errorRecoveryCTAModel = errorRecoveryCTAModel
        let errorRecoveryCTA = ErrorRecoveryCTA(model: errorRecoveryCTAModel)
        errorRecoveryViewController = UIHostingController(rootView: errorRecoveryCTA)
        errorRecoveryViewController.view.isHidden = true // initial state shows no error

        super.init(nibName: nil, bundle: nil)

        digitPadView.viewModel = digitPadViewModel
        continueButtonView.viewModel = continueButtonViewModel

        topAuxiliaryItemSeparatorView.viewModel = TitledSeparatorViewModel(separatorColor: .lightBorder)
        bottomAuxiliaryItemSeparatorView.viewModel = TitledSeparatorViewModel(separatorColor: .lightBorder)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .white

        let amountView = amountViewable.view
        view.addSubview(topAuxiliaryViewContainer)
        view.addSubview(topAuxiliaryItemSeparatorView)
        view.addSubview(amountView)
        view.addSubview(bottomAuxiliaryItemSeparatorView)
        view.addSubview(bottomAuxiliaryViewContainer)
        view.addSubview(digitPadView)

        topAuxiliaryViewContainer.layoutToSuperview(axis: .horizontal)
        topAuxiliaryViewContainer.layoutToSuperview(.top, usesSafeAreaLayoutGuide: true)
        topAuxiliaryViewHeightConstraint = topAuxiliaryViewContainer.layout(
            dimension: .height,
            to: Constant.Standard.topSelectionViewHeight
        )

        topAuxiliaryItemSeparatorView.layout(edge: .top, to: .bottom, of: topAuxiliaryViewContainer)
        topAuxiliaryItemSeparatorView.layoutToSuperview(.leading)
        topAuxiliaryItemSeparatorView.layoutToSuperview(.trailing)
        topAuxiliaryItemSeparatorView.layout(dimension: .height, to: 1)

        amountView.layoutToSuperview(axis: .horizontal)
        amountView.layout(edge: .top, to: .bottom, of: topAuxiliaryItemSeparatorView)

        bottomAuxiliaryItemSeparatorView.layout(edge: .top, to: .bottom, of: amountView)
        bottomAuxiliaryItemSeparatorView.layoutToSuperview(.leading, priority: .defaultHigh)
        bottomAuxiliaryItemSeparatorView.layoutToSuperview(.trailing)
        bottomAuxiliaryItemSeparatorView.layout(dimension: .height, to: 1)

        bottomAuxiliaryViewHeightConstraint = bottomAuxiliaryViewContainer.layout(
            dimension: .height,
            to: Constant.Standard.topSelectionViewHeight
        )

        let stackView = UIStackView(arrangedSubviews: [bottomAuxiliaryViewContainer, ctaContainerView])
        stackView.axis = .vertical
        stackView.spacing = 16

        view.addSubview(stackView)
        stackView.layoutToSuperview(.leading, .trailing)
        stackView.layout(
            edge: .top,
            to: .bottom,
            of: bottomAuxiliaryItemSeparatorView,
            priority: .defaultLow
        )
        stackView.layoutToSuperview(axis: .horizontal, offset: 24, priority: .penultimateHigh)

        ctaContainerView.layout(dimension: .height, to: 48)
        ctaContainerView.addSubview(continueButtonView)
        continueButtonView.constraint(edgesTo: ctaContainerView, insets: UIEdgeInsets(horizontal: 24, vertical: .zero))
        embed(errorRecoveryViewController, in: ctaContainerView, insets: UIEdgeInsets(horizontal: 24, vertical: .zero))
        digitPadView.layoutToSuperview(axis: .horizontal, priority: .penultimateHigh)
        digitPadView.layout(edge: .top, to: .bottom, of: stackView, offset: 16)
        digitPadView.layoutToSuperview(.bottom, usesSafeAreaLayoutGuide: true)
        digitPadHeightConstraint = digitPadView.layout(dimension: .height, to: 260, priority: .penultimateHigh)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // NOTE: This must be in `viewWillLayoutSubviews`
        // This is a special treatment due to the manner view controllers
        // are modally displayed on iOS 13 (with additional gap on the top that enable
        // dismissal of the screen.
        if view.bounds.height <= UIDevice.PhoneHeight.eight.rawValue {
            digitPadHeightConstraint.constant = Constant.SuperCompact.digitPadHeight
            if view.bounds.height <= UIDevice.PhoneHeight.se.rawValue {
                ctaTopConstraint.constant = Constant.SuperCompact.bottomAuxiliaryViewOffset
                topAuxiliaryViewHeightConstraint.constant = Constant.SuperCompact.topSelectionViewHeight
            }
        }
    }

    func connect(
        state: Driver<EnterAmountPageInteractor.State>
    ) -> Driver<EnterAmountPageInteractor.NavigationEffects> {
        state
            .distinctUntilChanged()
            .map(\.topAuxiliaryViewPresenter)
            .drive(weak: self) { (self, presenter) in
                self.topAuxiliaryViewModelStateDidChange(to: presenter)
            }
            .disposed(by: disposeBag)

        state
            .distinctUntilChanged()
            .map(\.bottomAuxiliaryViewPresenter)
            .drive(weak: self) { (self, presenter) in
                self.bottomAuxiliaryViewModelStateDidChange(to: presenter)
            }
            .disposed(by: disposeBag)

        ControlEvent.merge(rx.viewDidLoad.mapToVoid(), rx.viewWillAppear.mapToVoid())
            .asDriver(onErrorJustReturn: ())
            .flatMap { _ in
                state
            }
            .map(\.navigationModel)
            .drive(weak: self) { (self, model) in
                self.setupNavigationBar(model: model)
            }
            .disposed(by: disposeBag)

        let digitInput = digitPadView.viewModel
            .valueObservable
            .asDriverCatchError()

        let deleteInput = digitPadView.viewModel
            .backspaceButtonTapObservable
            .asDriverCatchError()

        let amountViewInputs = [
            digitInput
                .compactMap(\.first)
                .map { AmountPresenterInput.input($0) },
            deleteInput.map { AmountPresenterInput.delete }
        ]

        amountViewable.connect(input: Driver.merge(amountViewInputs))
            .drive()
            .disposed(by: disposeBag)

        state
            .distinctUntilChanged()
            .map(\.canContinue)
            .drive(continueButtonView.viewModel.isEnabledRelay)
            .disposed(by: disposeBag)

        state
            .distinctUntilChanged()
            .map(\.showContinueAction)
            .map { !$0 } // flip the flag because we're modifying the hidden state
            .drive(continueButtonView.viewModel.isHiddenRelay)
            .disposed(by: disposeBag)

        state
            .distinctUntilChanged()
            .map(\.showErrorRecoveryAction)
            .drive(onNext: { [weak errorRecoveryViewController] showError in
                errorRecoveryViewController?.view.isHidden = !showError
            })
            .disposed(by: disposeBag)

        state
            .distinctUntilChanged()
            .map { $0.showContinueAction || $0.showErrorRecoveryAction }
            .drive(onNext: { [ctaContainerView] canShowAnyCTA in
                ctaContainerView.isHidden = !canShowAnyCTA
            })
            .disposed(by: disposeBag)

        state
            .distinctUntilChanged()
            .map(\.errorState)
            .map(\.recoveryWarningHint)
            .drive(onNext: { [errorRecoveryCTAModel] errorTitle in
                errorRecoveryCTAModel.buttonTitle = errorTitle
            })
            .disposed(by: disposeBag)

        let backTapped = backTriggered
            .map { EnterAmountPageInteractor.NavigationEffects.back }

        let closeTapped = closeTriggerred
            .map { EnterAmountPageInteractor.NavigationEffects.close }

        return Observable.merge(backTapped, closeTapped)
            .asDriver(onErrorJustReturn: .none)
    }

    // MARK: - Setup

    private func setupNavigationBar(model: ScreenNavigationModel) {
        titleViewStyle = .text(value: displayBundle.title)
        let mayGoBack = model.leadingButton != .none ? (navigationController?.children.count ?? 0) > 1 : false
        set(
            barStyle: model.barStyle,
            leadingButtonStyle: mayGoBack ? .back : .none,
            trailingButtonStyle: model.trailingButton
        )
    }

    private func topAuxiliaryViewModelStateDidChange(to presenter: AuxiliaryViewPresenting?) {
        loadViewIfNeeded()
        remove(child: topAuxiliaryViewController)
        topAuxiliaryViewController = presenter?.makeViewController()

        if let viewController = topAuxiliaryViewController {
            topAuxiliaryViewHeightConstraint.constant = Constant.Standard.topSelectionViewHeight
            embed(viewController, in: topAuxiliaryViewContainer)
            topAuxiliaryItemSeparatorView.alpha = 1
        } else {
            topAuxiliaryViewHeightConstraint.constant = .zero
            topAuxiliaryItemSeparatorView.alpha = .zero
        }
    }

    private func bottomAuxiliaryViewModelStateDidChange(to presenter: AuxiliaryViewPresenting?) {
        loadViewIfNeeded()
        remove(child: bottomAuxiliaryViewController)
        bottomAuxiliaryViewController = presenter?.makeViewController()

        if let viewController = bottomAuxiliaryViewController {
            bottomAuxiliaryViewHeightConstraint.constant = Constant.Standard.bottomSelectionViewHeight
            embed(viewController, in: bottomAuxiliaryViewContainer)
            // NOTE: ATM this separator is unused as some auxiliary views already have one.
            bottomAuxiliaryItemSeparatorView.alpha = .zero
        } else {
            bottomAuxiliaryViewHeightConstraint.constant = .zero
            bottomAuxiliaryItemSeparatorView.alpha = .zero
        }
    }

    // MARK: - Navigation

    override func navigationBarLeadingButtonPressed() {
        backTriggered.onNext(())
    }

    override func navigationBarTrailingButtonPressed() {
        closeTriggerred.onNext(())
    }

    // MARK: - Withdrawal Locks

    func presentWithdrawalLocks(amountAvailable: String) {
        let store = Store<WithdrawalLocksInfoState, WithdrawalLocksInfoAction>(
            initialState: WithdrawalLocksInfoState(amountAvailable: amountAvailable),
            reducer: withdrawalLockInfoReducer,
            environment: WithdrawalLocksInfoEnvironment { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
        )
        let rootView = WithdrawalLocksInfoView(store: store)
        let viewController = UIHostingController(rootView: rootView)
        viewController.transitioningDelegate = bottomSheetPresenting
        viewController.modalPresentationStyle = .custom
        present(viewController, animated: true, completion: nil)
    }
}

extension UIViewController {

    func embed(_ viewController: UIViewController, in subview: UIView, insets: UIEdgeInsets = .zero) {
        addChild(viewController)
        subview.addSubview(viewController.view)
        viewController.view.constraint(edgesTo: subview, insets: insets)
    }

    func remove(child: UIViewController?) {
        guard let child = child, child.parent === self else {
            return
        }
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
}
