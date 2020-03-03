//
//  SimpleBuyTransferCancellationViewController.swift
//  Blockchain
//
//  Created by AlexM on 2/24/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformUIKit

final class SimpleBuyTransferCancellationViewController: UIViewController {
    
    // MARK: - Private IBOutlets
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var noButtonView: ButtonView!
    @IBOutlet private var yesButtonView: ButtonView!
    
    // MARK: - Injected
    
    private let presenter: SimpleBuyTransferCancellationScreenPresenter
    
    // MARK: - Private Properties
    
    private let disposeBag = DisposeBag()

    // MARK: - Setup
    
    init(presenter: SimpleBuyTransferCancellationScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: SimpleBuyTransferCancellationViewController.objectName, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noButtonView.viewModel = presenter.noButtonViewModel
        yesButtonView.viewModel = presenter.yesButtonViewModel
        titleLabel.content = presenter.titleContent
        descriptionLabel.content = presenter.descriptionContent
        
        presenter.dismissalRelay
            .observeOn(MainScheduler.instance)
            .bind(weak: self) { (self) in
                self.dismiss(animated: true, completion: nil)
            }
        .disposed(by: disposeBag)
        
        presenter.viewDidLoad()
    }
}
