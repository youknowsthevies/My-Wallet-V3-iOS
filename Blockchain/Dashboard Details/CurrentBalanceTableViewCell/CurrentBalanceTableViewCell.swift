//
//  CurrentBalanceTableViewCell.swift
//  Blockchain
//
//  Created by AlexM on 11/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import RxSwift
import PlatformKit
import PlatformUIKit

final class CurrentBalanceTableViewCell: UITableViewCell {
    
    var presenter: CurrentBalanceCellPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            assetBalanceView.presenter = presenter?.assetBalanceViewPresenter
            guard let presenter = presenter else { return }
            
            presenter.imageViewContent
                .drive(thumbImageView.rx.content)
                .disposed(by: disposeBag)
            
            presenter.iconImageViewContent
                .drive(thumbSideImageView.rx.content)
                .disposed(by: disposeBag)
            
            presenter.title
                .drive(titleLabel.rx.text)
                .disposed(by: disposeBag)
            
            presenter.description
                .drive(descriptionLabel.rx.text)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Private Properties
    
    private var disposeBag = DisposeBag()
    
    // MARK: - Private IBOutlets

    @IBOutlet private var thumbImageView: UIImageView!
    @IBOutlet private var thumbSideImageView: UIImageView!

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!

    @IBOutlet private var assetBalanceView: AssetBalanceView!
    
    // MARK: - Lifecycle
       
    override func awakeFromNib() {
        super.awakeFromNib()
        assetBalanceView.shimmer(
            estimatedFiatLabelSize: CGSize(width: 90, height: 16),
            estimatedCryptoLabelSize: CGSize(width: 100, height: 14)
        )
    }
       
    override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }
}
