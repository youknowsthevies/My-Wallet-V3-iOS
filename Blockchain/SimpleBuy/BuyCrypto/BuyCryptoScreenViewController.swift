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
            static let amountLabelViewTopOffset: CGFloat = 16
            static let continueButtonViewBottomOffset: CGFloat = 16
            static let assetSelectionButtonHeight: CGFloat = 48
        }
        enum Compact {
            static let amountLabelViewTopOffset: CGFloat = 32
        }
    }
    
    // MARK: - Properties
    
    @IBOutlet private var assetSelectionButtonView: SelectionButtonView!
    private var labeledButtonCollectionView: LabeledButtonCollectionView<CurrencyLabeledButtonViewModel>!
    @IBOutlet private var trailingButtonView: ButtonView!
    @IBOutlet private var amountLabelView: AmountLabelView!
    @IBOutlet private var continueButtonView: ButtonView!
    @IBOutlet private var separatorView: UIView!
    @IBOutlet private var digitPadView: DigitPadView!

    @IBOutlet private var assetSelectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var digitPadHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var amountLabelViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private var continueButtonViewBottomConstraint: NSLayoutConstraint!

    // MARK: - Injected
    
    private let presenter: BuyCryptoScreenPresenter
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    init(presenter: BuyCryptoScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: "BuyCryptoScreenViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupLabeledButtonCollectionView()
        digitPadView.viewModel = presenter.digitPadViewModel
        separatorView.backgroundColor = presenter.separatorColor
        continueButtonView.viewModel = presenter.continueButtonViewModel
        amountLabelView.viewModel = presenter.amountLabelViewModel
        assetSelectionButtonView.viewModel = presenter.selectionButtonViewModel
        presenter.labeledButtonViewModels
            .drive(labeledButtonCollectionView.viewModelsRelay)
            .disposed(by: disposeBag)
        trailingButtonView.viewModel = presenter.trailingButtonViewModel

        presenter.refresh()
        
        if presenter.deviceType == .superCompact {
            digitPadHeightConstraint.constant = Constant.SuperCompact.digitPadHeight
            amountLabelViewTopConstraint.constant = Constant.SuperCompact.amountLabelViewTopOffset
            continueButtonViewBottomConstraint.constant = Constant.SuperCompact.continueButtonViewBottomOffset
            assetSelectionViewHeightConstraint.constant = Constant.SuperCompact.assetSelectionButtonHeight
        } else if presenter.deviceType == .compact {
            amountLabelViewTopConstraint.constant = Constant.Compact.amountLabelViewTopOffset
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        titleViewStyle = .text(value: presenter.title)
        set(barStyle: .lightContent(ignoresStatusBar: false, background: .navigationBarBackground),
            leadingButtonStyle: .back, trailingButtonStyle: .none)
    }
    
    private func setupLabeledButtonCollectionView() {
        labeledButtonCollectionView = LabeledButtonCollectionView<CurrencyLabeledButtonViewModel>()
        view.insertSubview(labeledButtonCollectionView, belowSubview: trailingButtonView)
        labeledButtonCollectionView.layout(to: .centerY, of: trailingButtonView)
        labeledButtonCollectionView.layoutToSuperview(axis: .horizontal)
        labeledButtonCollectionView.layout(dimension: .height, to: 32)
        labeledButtonCollectionView.layout(edge: .bottom, to: .top, of: continueButtonView, offset: -16)
    }
    
    // MARK: - Navigation
    
    override func navigationBarLeadingButtonPressed() {
        presenter.navigationBarLeadingButtonTapped()
    }
}
