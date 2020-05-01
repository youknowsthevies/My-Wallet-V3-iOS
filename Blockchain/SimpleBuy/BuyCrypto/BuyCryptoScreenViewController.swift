//
//  BuyCryptoScreenViewController.swift
//  Blockchain
//
//  Created by Daniel Huri on 21/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import PlatformKit
import PlatformUIKit

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
    
    @IBOutlet private var assetSelectionButtonView: SelectionButtonView!
    @IBOutlet private var amountLabelView: AmountLabelView!
    @IBOutlet private var amountLabelContainerView: UIView!
    private var labeledButtonCollectionView: LabeledButtonCollectionView<CurrencyLabeledButtonViewModel>!
    @IBOutlet private var trailingButtonView: ButtonView!
    @IBOutlet private var paymentMethodSelectionButtonView: SelectionButtonView!
    @IBOutlet private var continueButtonView: ButtonView!
    @IBOutlet private var separatorViews: [UIView]!
    @IBOutlet private var digitPadView: DigitPadView!

    @IBOutlet private var assetSelectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var paymentMethodSelectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var paymentMethodSelectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var digitPadHeightConstraint: NSLayoutConstraint!
    
    private var amountContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var continueButtonViewBottomConstraint: NSLayoutConstraint!

    // MARK: - Injected
    
    private let presenter: BuyCryptoScreenPresenter
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    init(presenter: BuyCryptoScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: BuyCryptoScreenViewController.objectName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupLabeledButtonCollectionView()
        digitPadView.viewModel = presenter.digitPadViewModel
        separatorViews.forEach { $0.backgroundColor = presenter.separatorColor }
        continueButtonView.viewModel = presenter.continueButtonViewModel
        amountLabelView.viewModel = presenter.amountLabelViewModel
        assetSelectionButtonView.viewModel = presenter.assetSelectionButtonViewModel
        
        setupPaymentMethodSelectionButtonView()
        
        presenter.labeledButtonViewModels
            .drive(labeledButtonCollectionView.viewModelsRelay)
            .disposed(by: disposeBag)
        trailingButtonView.viewModel = presenter.trailingButtonViewModel

        presenter.refresh()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        /// NOTE: This must be in `viewWillLayoutSubviews`
        /// This is a special treatment due to the manner view controllers
        /// are modally displayed on iOS 13 (with additional gap on the top that enable
        /// dismissal of the screen.
        if view.bounds.height < UIDevice.PhoneHeight.eight.rawValue {
            digitPadHeightConstraint.constant = Constant.SuperCompact.digitPadHeight
            continueButtonViewBottomConstraint.constant = Constant.SuperCompact.continueButtonViewBottomOffset
            if view.bounds.height <= UIDevice.PhoneHeight.se.rawValue {
                paymentMethodSelectionViewBottomConstraint.constant = Constant.SuperCompact.paymentMethodSelectionBottomOffset
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
    
    private func setupLabeledButtonCollectionView() {
        labeledButtonCollectionView = LabeledButtonCollectionView<CurrencyLabeledButtonViewModel>()
        view.insertSubview(labeledButtonCollectionView, belowSubview: trailingButtonView)
        labeledButtonCollectionView.layout(to: .centerY, of: trailingButtonView)
        labeledButtonCollectionView.layoutToSuperview(axis: .horizontal)
        labeledButtonCollectionView.layout(dimension: .height, to: 32)
        labeledButtonCollectionView.layout(edge: .bottom, to: .top, of: paymentMethodSelectionButtonView, offset: -16)
        
        amountContainerBottomConstraint = amountLabelContainerView.layout(
            edge: .bottom,
            to: .top,
            of: labeledButtonCollectionView
        )
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
