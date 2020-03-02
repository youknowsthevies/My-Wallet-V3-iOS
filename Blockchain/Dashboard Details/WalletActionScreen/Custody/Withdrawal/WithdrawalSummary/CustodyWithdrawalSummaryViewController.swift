//
//  CustodyWithdrawalSummaryViewController.swift
//  Blockchain
//
//  Created by AlexM on 2/14/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit
import PlatformUIKit

final class CustodyWithdrawalSummaryViewController: BaseScreenViewController {
    
    // MARK: - Private IBOutlets
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var actionButtonView: ButtonView!
    
    // MARK: - Private Properties
    
    private let presenter: CustodyWithdrawalSummaryPresenter
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    
    init(presenter: CustodyWithdrawalSummaryPresenter) {
        self.presenter = presenter
        super.init(nibName: CustodyWithdrawalSummaryViewController.objectName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleViewStyle = presenter.titleView
        set(barStyle: presenter.barStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: presenter.trailingButton)
        
        presenter.imageDriver
            .drive(imageView.rx.image)
            .disposed(by: disposeBag)
        
        presenter.titleLabelDriver
            .drive(titleLabel.rx.content)
            .disposed(by: disposeBag)
        
        presenter.descriptionLabelDriver
            .drive(descriptionLabel.rx.content)
            .disposed(by: disposeBag)
        
        actionButtonView.viewModel = presenter.actionViewModel
    }
    
    override func navigationBarTrailingButtonPressed() {
        presenter.navigationBarTrailingButtonTapped()
    }
    
    override func navigationBarLeadingButtonPressed() {
        presenter.navigationBarLeadingButtonTapped()
    }
}
