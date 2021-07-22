// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformUIKit
import RxCocoa
import RxSwift
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
        }
    }

    // MARK: - Properties

    private let topSelectionButtonView = SelectionButtonView()
    private let amountViewable: AmountViewable
    private let bottomAuxiliaryItemSeparatorView = TitledSeparatorView()
    private let bottomAuxiliaryView = UIView()
    private let continueButtonView = ButtonView()
    private let digitPadView = DigitPadView()

    private var topSelectionViewHeightConstraint: NSLayoutConstraint!
    private var bottomAuxiliaryButtonViewHeightConstraint: NSLayoutConstraint!
    private var digitPadHeightConstraint: NSLayoutConstraint!
    private var continueButtonTopConstraint: NSLayoutConstraint!
    private var digitPadSeparatorTopConstraint: NSLayoutConstraint!

    private let closeTriggerred = PublishSubject<Void>()
    private let backTriggered = PublishSubject<Void>()

    internal let continueButtonTapped: Signal<Void>

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
        topSelectionButtonViewModel: SelectionButtonViewModel,
        amountViewProvider: AmountViewable
    ) {
        self.displayBundle = displayBundle
        self.devicePresenterType = devicePresenterType
        amountViewable = amountViewProvider
        continueButtonTapped = continueButtonViewModel.tap
        super.init(nibName: nil, bundle: nil)

        digitPadView.viewModel = digitPadViewModel
        continueButtonView.viewModel = continueButtonViewModel
        topSelectionButtonView.viewModel = topSelectionButtonViewModel
        bottomAuxiliaryItemSeparatorView.viewModel = TitledSeparatorViewModel()

        bottomAuxiliaryButtonViewHeightConstraint = bottomAuxiliaryView.layout(
            dimension: .height,
            to: 1
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override public func loadView() {
        view = UIView()
        view.backgroundColor = .white

        let digitPadTopSeparatorView = UIView()

        let amountView = amountViewable.view
        view.addSubview(topSelectionButtonView)
        view.addSubview(amountView)
        view.addSubview(bottomAuxiliaryItemSeparatorView)
        view.addSubview(bottomAuxiliaryView)
        view.addSubview(continueButtonView)
        view.addSubview(digitPadTopSeparatorView)
        view.addSubview(digitPadView)

        topSelectionButtonView.layoutToSuperview(.top, usesSafeAreaLayoutGuide: true)
        topSelectionButtonView.layoutToSuperview(axis: .horizontal)
        topSelectionViewHeightConstraint = topSelectionButtonView.layout(dimension: .height, to: 78)

        amountView.layoutToSuperview(axis: .horizontal)
        amountView.layout(edge: .top, to: .bottom, of: topSelectionButtonView)

        bottomAuxiliaryItemSeparatorView.layout(edge: .top, to: .bottom, of: amountView)
        bottomAuxiliaryItemSeparatorView.layoutToSuperview(.leading, offset: 24, priority: .defaultHigh)
        bottomAuxiliaryItemSeparatorView.layoutToSuperview(.trailing)

        bottomAuxiliaryView.layoutToSuperview(.leading, .trailing)
        bottomAuxiliaryView.layout(
            edge: .top,
            to: .bottom,
            of: bottomAuxiliaryItemSeparatorView,
            priority: .defaultLow
        )

        continueButtonView.layoutToSuperview(axis: .horizontal, offset: 24, priority: .penultimateHigh)
        continueButtonTopConstraint = continueButtonView.layout(
            edge: .top,
            to: .bottom,
            of: bottomAuxiliaryView,
            offset: 16
        )
        continueButtonView.layout(dimension: .height, to: 48)

        digitPadTopSeparatorView.layoutToSuperview(.leading, .trailing)
        digitPadSeparatorTopConstraint = digitPadTopSeparatorView.layout(
            edge: .top,
            to: .bottom,
            of: continueButtonView,
            offset: 24
        )
        digitPadTopSeparatorView.layout(dimension: .height, to: 1)

        digitPadView.layoutToSuperview(axis: .horizontal, priority: .penultimateHigh)
        digitPadView.layout(edge: .top, to: .bottom, of: digitPadTopSeparatorView)
        digitPadView.layoutToSuperview(.bottom, usesSafeAreaLayoutGuide: true)
        digitPadHeightConstraint = digitPadView.layout(dimension: .height, to: 260, priority: .penultimateHigh)

        digitPadTopSeparatorView.backgroundColor = .lightBorder
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        /// NOTE: This must be in `viewWillLayoutSubviews`
        /// This is a special treatment due to the manner view controllers
        /// are modally displayed on iOS 13 (with additional gap on the top that enable
        /// dismissal of the screen.
        if view.bounds.height <= UIDevice.PhoneHeight.eight.rawValue {
            digitPadHeightConstraint.constant = Constant.SuperCompact.digitPadHeight
            digitPadSeparatorTopConstraint.constant = Constant.SuperCompact.continueButtonViewBottomOffset
            if view.bounds.height <= UIDevice.PhoneHeight.se.rawValue {
                continueButtonTopConstraint.constant = Constant.SuperCompact.bottomAuxiliaryViewOffset
                topSelectionViewHeightConstraint.constant = Constant.SuperCompact.topSelectionViewHeight
            }
        }
    }

    func connect(state: Driver<EnterAmountPageInteractor.State>) -> Driver<EnterAmountPageInteractor.NavigationEffects> {

        let topSelection = state.map(\.topSelection)

        topSelection.map(\.title)
            .drive(topSelectionButtonView.viewModel.titleRelay)
            .disposed(by: disposeBag)
        topSelection.map(\.subtitle)
            .drive(topSelectionButtonView.viewModel.subtitleRelay)
            .disposed(by: disposeBag)
        topSelection.map(\.titleAccessibility)
            .drive(topSelectionButtonView.viewModel.titleAccessibilityRelay)
            .disposed(by: disposeBag)
        topSelection.map(\.subtitleAccessibility)
            .drive(topSelectionButtonView.viewModel.subtitleAccessibilityRelay)
            .disposed(by: disposeBag)
        topSelection.map(\.isEnabled)
            .drive(topSelectionButtonView.viewModel.isButtonEnabledRelay)
            .disposed(by: disposeBag)
        topSelection.map(\.leadingContent)
            .drive(topSelectionButtonView.viewModel.leadingContentTypeRelay)
            .disposed(by: disposeBag)
        topSelection.map(\.trailingContent)
            .drive(topSelectionButtonView.viewModel.trailingContentRelay)
            .disposed(by: disposeBag)
        topSelection.map(\.titleDescriptor.font)
            .drive(topSelectionButtonView.viewModel.titleFontRelay)
            .disposed(by: disposeBag)
        topSelection.map(\.titleDescriptor.textColor)
            .drive(topSelectionButtonView.viewModel.titleFontColor)
            .disposed(by: disposeBag)
        topSelection.map(\.subtitleDescriptor.font)
            .drive(topSelectionButtonView.viewModel.subtitleFontRelay)
            .disposed(by: disposeBag)
        topSelection.map(\.subtitleDescriptor.textColor)
            .drive(topSelectionButtonView.viewModel.subtitleFontColor)
            .disposed(by: disposeBag)

        state.map(\.bottomAuxiliaryState)
            .distinctUntilChanged()
            .drive(weak: self) { (self, state) in
                self.bottomAuxiliaryViewModelStateDidChange(to: state)
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

        state.map(\.canContinue)
            .drive(continueButtonView.viewModel.isEnabledRelay)
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

    private func bottomAuxiliaryViewModelStateDidChange(to state: EnterAmountPageInteractor.BottomAuxiliaryViewModelState) {
        let height: CGFloat
        let visibility: Visibility
        let subviewsToRemove: [UIView]
        switch state {
        case .hidden:
            subviewsToRemove = bottomAuxiliaryView.subviews
            height = 0.5
            visibility = .hidden
        case .account(let presenter):
            subviewsToRemove = []
            let accountAuxiliaryView: AccountAuxiliaryView
            if let view = bottomAuxiliaryView.subviews.first(where: { $0 is AccountAuxiliaryView }) as? AccountAuxiliaryView {
                accountAuxiliaryView = view
            } else {
                accountAuxiliaryView = AccountAuxiliaryView()
                bottomAuxiliaryView.addSubview(accountAuxiliaryView)
                accountAuxiliaryView.fillSuperview()
            }
            accountAuxiliaryView.presenter = presenter
            visibility = .visible
            height = Constant.Standard.topSelectionViewHeight
        case .send(let presenter):
            subviewsToRemove = []
            let sendAuxiliaryView: SendAuxiliaryView
            if let view = bottomAuxiliaryView.subviews.first(where: { $0 is SendAuxiliaryView }) {
                sendAuxiliaryView = view as! SendAuxiliaryView
            } else {
                sendAuxiliaryView = SendAuxiliaryView()
                bottomAuxiliaryView.addSubview(sendAuxiliaryView)
                sendAuxiliaryView.fillSuperview()
            }
            sendAuxiliaryView.presenter = presenter
            visibility = .visible
            height = Constant.Standard.topSelectionViewHeight
        }
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [.beginFromCurrentState, .curveEaseOut],
            animations: {
                self.bottomAuxiliaryItemSeparatorView.alpha = visibility.defaultAlpha
                self.bottomAuxiliaryView.alpha = visibility.defaultAlpha
                self.bottomAuxiliaryButtonViewHeightConstraint.constant = height
            },
            completion: { _ in
                subviewsToRemove.forEach { $0.removeFromSuperview() }
            }
        )
    }

    // MARK: - Navigation

    override public func navigationBarLeadingButtonPressed() {
        backTriggered.onNext(())
    }

    override public func navigationBarTrailingButtonPressed() {
        closeTriggerred.onNext(())
    }
}
