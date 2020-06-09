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
                .map {
                    .init(text: $0,
                          font: .main(.semibold, 16.0),
                          color: .titleText,
                          alignment: .left,
                          accessibility: .id(presenter.titleAccessibilitySuffix))
                }
                .drive(titleLabel.rx.content)
                .disposed(by: disposeBag)
            
            presenter.description
                .map {
                    .init(text: $0,
                          font: .main(.medium, 14.0),
                          color: .descriptionText,
                          alignment: .left,
                          accessibility: .id(presenter.descriptionAccessibilitySuffix))
                }
                .drive(descriptionLabel.rx.content)
                .disposed(by: disposeBag)
            
            presenter.separatorVisibility
                .map { $0.defaultAlpha }
                .drive(separatorView.rx.alpha)
                .disposed(by: disposeBag)
            
            presenter.separatorVisibility
                .map { $0.isHidden ? 0 : 1 }
                .drive(separatorHeightConstraint.rx.constant)
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

    @IBOutlet private var separatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var separatorView: UIView!
    @IBOutlet private var assetBalanceView: AssetBalanceView!
    
    // MARK: - Lifecycle
       
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorView.backgroundColor = .lightBorder
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
