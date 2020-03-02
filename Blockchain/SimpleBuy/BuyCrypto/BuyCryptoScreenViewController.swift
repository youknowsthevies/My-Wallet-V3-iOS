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
        static let digitPadHeight: CGFloat = 216
        static let amountLabelViewTopOffsetiPhone5: CGFloat = 16
        static let amountLabelViewTopOffsetiPhone8: CGFloat = 32
        static let continueButtonViewBottomOffset: CGFloat = 16
    }
    
    // MARK: - Properties
    
    @IBOutlet private var assetSelectionButtonView: SelectionButtonView!
    private var labeledButtonCollectionView: LabeledButtonCollectionView<CurrencyLabeledButtonViewModel>!
    @IBOutlet private var amountLabelView: AmountLabelView!
    @IBOutlet private var correctionLinkView: LinkView!
    @IBOutlet private var continueButtonView: ButtonView!
    @IBOutlet private var separatorView: UIView!
    @IBOutlet private var digitPadView: DigitPadView!

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
        correctionLinkView.viewModel = presenter.correctionLinkViewModel
        amountLabelView.viewModel = presenter.amountLabelViewModel
        assetSelectionButtonView.viewModel = presenter.selectionButtonViewModel
        presenter.labeledButtonViewModels
            .drive(labeledButtonCollectionView.viewModelsRelay)
            .disposed(by: disposeBag)
        presenter.refresh()
        
        if presenter.deviceType.isBelow(.iPhone8) {
            digitPadHeightConstraint.constant = Constant.digitPadHeight
            amountLabelViewTopConstraint.constant = Constant.amountLabelViewTopOffsetiPhone5
            continueButtonViewBottomConstraint.constant = Constant.continueButtonViewBottomOffset
        } else if presenter.deviceType.isBelow(.iPhoneXS) {
            amountLabelViewTopConstraint.constant = Constant.amountLabelViewTopOffsetiPhone8
        }
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        titleViewStyle = .text(value: presenter.title)
        set(barStyle: .lightContent(ignoresStatusBar: false, background: .navigationBarBackground),
            leadingButtonStyle: .back, trailingButtonStyle: .none)
    }
    
    private func setupLabeledButtonCollectionView() {
        labeledButtonCollectionView = LabeledButtonCollectionView<CurrencyLabeledButtonViewModel>()
        view.addSubview(labeledButtonCollectionView)
        labeledButtonCollectionView.layoutToSuperview(axis: .horizontal)
        labeledButtonCollectionView.layout(edge: .height, to: 50)
        labeledButtonCollectionView.layout(edge: .bottom, to: .top, of: continueButtonView, offset: -16)
    }
    
    // MARK: - Navigation
    
    override func navigationBarLeadingButtonPressed() {
        presenter.navigationBarLeadingButtonTapped()
    }
}
