//
//  LinkedCardTableViewCell.swift
//  Blockchain
//
//  Created by Alex McGregor on 3/24/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa
import PlatformUIKit

final class LinkedCardTableViewCell: UITableViewCell {
    
    // MARK: - Public Properites
    
    var presenter: LinkedCardCellPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let presenter = presenter else { return }
            
            linkedCardView.viewModel = presenter.linkedCardViewModel
            cardDigitsLabel.content = presenter.digitsLabelContent
            expirationDateLabel.content = presenter.expirationLabelContent
            expiredBadgeView.viewModel = presenter.expiredBadgeViewModel
            
            presenter.expiredBadgeVisibility
                .map { $0.isHidden }
                .drive(expiredBadgeView.rx.isHidden)
                .disposed(by: disposeBag)
            
            presenter.expiredBadgeVisibility
                .map { $0.invertedAlpha }
                .drive(cardDigitsLabel.rx.alpha)
                .disposed(by: disposeBag)
            
            presenter.expiredBadgeVisibility
                .map { $0.invertedAlpha }
                .drive(expirationDateLabel.rx.alpha)
                .disposed(by: disposeBag)
        }
    }
    
    // MARK: - Private IBOutlets
    
    @IBOutlet private var linkedCardView: LinkedCardView!
    @IBOutlet private var cardDigitsLabel: UILabel!
    @IBOutlet private var expirationDateLabel: UILabel!
    @IBOutlet private var expiredBadgeView: BadgeView!
    
    // MARK: - Rx
    
    private var disposeBag = DisposeBag()
    
}
