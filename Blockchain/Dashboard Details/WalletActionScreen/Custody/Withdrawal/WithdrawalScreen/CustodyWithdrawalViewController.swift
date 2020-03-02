//
//  SimpleBuyWithdrawalViewController.swift
//  Blockchain
//
//  Created by AlexM on 2/12/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxCocoa
import RxSwift

final class CustodyWithdrawalViewController: BaseScreenViewController {
    
    // MARK: - Private IBOutlets
    
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var assetBalanceView: AssetBalanceView!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var sendButtonView: ButtonView!
    
    // MARK: - Private Properties
    
    private let presenter: CustodyWithdrawalScreenPresenter
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(presenter: CustodyWithdrawalScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: CustodyWithdrawalViewController.objectName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assetBalanceView.presenter = presenter.assetBalanceViewPresenter
        descriptionLabel.content = presenter.descriptionLabel
        titleViewStyle = presenter.titleView
        sendButtonView.viewModel = presenter.sendButtonViewModel
        set(barStyle: presenter.barStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: presenter.trailingButton)
        
        presenter.activityIndicatorVisibility
            .map { $0.isHidden == false }
            .drive(activityIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
        
        presenter.balanceViewVisibility
            .map { $0.defaultAlpha }
            .drive(assetBalanceView.rx.alpha)
            .disposed(by: disposeBag)
    }
    
    override func navigationBarTrailingButtonPressed() {
        presenter.navigationBarTrailingButtonTapped()
    }
    
    override func navigationBarLeadingButtonPressed() {
        presenter.navigationBarLeadingButtonTapped()
    }
}
