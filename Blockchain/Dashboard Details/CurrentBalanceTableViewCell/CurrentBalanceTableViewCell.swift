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
        didSet {
            disposeBag = DisposeBag()
            guard let presenter = presenter else { return }
            assetBalanceView.presenter = presenter.assetBalanceViewPresenter
            
            presenter.custodialVisibility
                .map { $0.defaultAlpha }
                .drive(custodyImageView.rx.alpha)
                .disposed(by: disposeBag)
            
            presenter.description
                .drive(currencyTypeDescription.rx.text)
                .disposed(by: disposeBag)
        }
    }
    
    var currency: CryptoCurrency! {
        didSet {
            currencyImageView.image = currency.logo
            currencyType.text = currency.name
        }
    }
    
    // MARK: - Private Properties
    
    private var disposeBag = DisposeBag()
    
    // MARK: - Private IBOutlets
    
    @IBOutlet private var custodyImageView: UIImageView!
    @IBOutlet private var currencyImageView: UIImageView!
    @IBOutlet private var currencyType: UILabel!
    @IBOutlet private var currencyTypeDescription: UILabel!
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
        assetBalanceView.presenter = nil
    }
}
