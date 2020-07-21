//
//  BuyCryptoScreenViewController.swift
//  Blockchain
//
//  Created by Daniel Huri on 21/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

/// A screen that allows the end-user to specify the amount of crypto he wishes to buy
final class BuyCryptoScreenViewController: BaseScreenViewController {

    // MARK: - Types

    private enum Constant {
        enum SuperCompact {
            static let digitPadHeight: CGFloat = 216
            static let continueButtonViewBottomOffset: CGFloat = 16
            static let selectionButtonHeight: CGFloat = 48
            static let paymentMethodSelectionBottomOffset: CGFloat = 8
        }
        enum Standard {
            static let selectionButtonHeight: CGFloat = 78
        }
    }
    
    // MARK: - Properties
    
    private let paymentMethodSeparatorView = TitledSeparatorView()
    private let assetSelectionButtonView = SelectionButtonView()
    private var amountTranslationView: AmountTranslationView!
    private let paymentMethodSelectionButtonView = SelectionButtonView()
    private let continueButtonView = ButtonView()
    private let digitPadView = DigitPadView()

    private var assetSelectionViewHeightConstraint: NSLayoutConstraint!
    private var paymentMethodSelectionViewHeightConstraint: NSLayoutConstraint!
    private var digitPadHeightConstraint: NSLayoutConstraint!
    private var continueButtonTopConstraint: NSLayoutConstraint!
    private var digitPadSeparatorTopConstraint: NSLayoutConstraint!

    // MARK: - Injected
    
    private let presenter: BuyCryptoScreenPresenter
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    init(presenter: BuyCryptoScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
                
        let digitPadTopSeparatorView = UIView()

        amountTranslationView = AmountTranslationView(presenter: presenter.amountTranslationPresenter)
        
        view.addSubview(assetSelectionButtonView)
        view.addSubview(amountTranslationView)
        view.addSubview(paymentMethodSeparatorView)
        view.addSubview(paymentMethodSelectionButtonView)
        view.addSubview(continueButtonView)
        view.addSubview(digitPadTopSeparatorView)
        view.addSubview(digitPadView)
        
        assetSelectionButtonView.layoutToSuperview(.top, usesSafeAreaLayoutGuide: true)
        assetSelectionButtonView.layoutToSuperview(.leading, .trailing)
        assetSelectionViewHeightConstraint = assetSelectionButtonView.layout(dimension: .height, to: 78)
        
        amountTranslationView.layoutToSuperview(axis: .horizontal)
        amountTranslationView.layout(edge: .top, to: .bottom, of: assetSelectionButtonView)

        paymentMethodSeparatorView.layout(edge: .top, to: .bottom, of: amountTranslationView)
        paymentMethodSeparatorView.layoutToSuperview(.leading, offset: 24, priority: .defaultHigh)
        paymentMethodSeparatorView.layoutToSuperview(.trailing)

        paymentMethodSelectionButtonView.layoutToSuperview(.leading, .trailing)
        paymentMethodSelectionButtonView.layout(
            edge: .top,
            to: .bottom,
            of: paymentMethodSeparatorView,
            priority: .defaultLow
        )
        paymentMethodSelectionViewHeightConstraint = paymentMethodSelectionButtonView.layout(
            dimension: .height,
            to: 78
        )
        
        continueButtonView.layoutToSuperview(axis: .horizontal, offset: 24, priority: .penultimateHigh)
        continueButtonTopConstraint = continueButtonView.layout(
            edge: .top,
            to: .bottom,
            of: paymentMethodSelectionButtonView,
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
                
        digitPadTopSeparatorView.backgroundColor = presenter.separatorColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        digitPadView.viewModel = presenter.digitPadViewModel
        continueButtonView.viewModel = presenter.continueButtonViewModel
        assetSelectionButtonView.viewModel = presenter.assetSelectionButtonViewModel
        paymentMethodSeparatorView.viewModel = presenter.paymentMethodSeparatorViewModel
        setupPaymentMethodSelectionButtonView()
        presenter.refresh()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        /// NOTE: This must be in `viewWillLayoutSubviews`
        /// This is a special treatment due to the manner view controllers
        /// are modally displayed on iOS 13 (with additional gap on the top that enable
        /// dismissal of the screen.
        if view.bounds.height <= UIDevice.PhoneHeight.eight.rawValue {
            digitPadHeightConstraint.constant = Constant.SuperCompact.digitPadHeight
            digitPadSeparatorTopConstraint.constant = Constant.SuperCompact.continueButtonViewBottomOffset
            if view.bounds.height <= UIDevice.PhoneHeight.se.rawValue {
                continueButtonTopConstraint.constant = Constant.SuperCompact.paymentMethodSelectionBottomOffset
                assetSelectionViewHeightConstraint.constant = Constant.SuperCompact.selectionButtonHeight
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        titleViewStyle = .text(value: presenter.title)
        setStandardDarkContentStyle()
    }
        
    private func setupPaymentMethodSelectionButtonView() {
        presenter.paymentMethodSelectionButtonViewModelState
            .drive(
                onNext: { [weak self] state in
                    self?.paymentMethodStateDidChange(to: state)
                }
           )
           .disposed(by: disposeBag)
    }
    
    private func paymentMethodStateDidChange(
        to state: BuyCryptoScreenPresenter.PaymentMethodSelectionButtonViewModelState
    ) {
        let height: CGFloat
        let visibility: Visibility
        switch state {
        case .hidden:
            height = 0.5
            visibility = .hidden
        case .visible(let viewModel):
            paymentMethodSelectionButtonView.viewModel = viewModel
            visibility = .visible
            if presenter.deviceType == .superCompact {
                height = Constant.SuperCompact.selectionButtonHeight
            } else {
                height = Constant.Standard.selectionButtonHeight
            }
        }
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [.beginFromCurrentState, .curveEaseOut],
            animations: {
                self.paymentMethodSeparatorView.alpha = visibility.defaultAlpha
                self.paymentMethodSelectionButtonView.alpha = visibility.defaultAlpha
                self.paymentMethodSelectionViewHeightConstraint.constant = height
            },
            completion: nil
        )
    }
    
    // MARK: - Navigation
    
    override func navigationBarLeadingButtonPressed() {
        presenter.previous()
    }
    
    override func navigationBarTrailingButtonPressed() {
        presenter.previous()
    }
}
