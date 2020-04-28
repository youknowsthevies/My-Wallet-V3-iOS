//
//  RemoveCardViewController.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/9/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxSwift

final class RemoveCardViewController: UIViewController {
    
    // MARK: - Private IBOutlets
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var badgeImageView: BadgeImageView!
    @IBOutlet private var removeCardButtonView: ButtonView!
    
    // MARK: - Injected
    
    private let presenter: RemoveCardScreenPresenter
    private let disposeBag = DisposeBag()

    // MARK: - Setup
    
    init(presenter: RemoveCardScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: RemoveCardViewController.objectName, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        removeCardButtonView.viewModel = presenter.removeButtonViewModel
        badgeImageView.viewModel = presenter.badgeImageViewModel
        titleLabel.content = presenter.titleLabelContent
        descriptionLabel.content = presenter.descriptionLabelContent
        
        presenter.dismissalRelay
            .observeOn(MainScheduler.instance)
            .bind(weak: self) { (self) in
                self.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        
    }
}
