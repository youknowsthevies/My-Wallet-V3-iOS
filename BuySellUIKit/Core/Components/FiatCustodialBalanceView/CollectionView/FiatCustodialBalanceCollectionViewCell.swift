//
//  FiatCustodialBalanceCollectionViewCell.swift
//  PlatformUIKit
//
//  Created by Daniel on 13/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import PlatformUIKit

final class FiatCustodialBalanceCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
    
    var presenter: FiatCustodialBalanceViewPresenter! {
        didSet {
            custodialBalanceView.presenter = presenter
            
            guard let presenter = presenter else {
                return
            }
            switch presenter.presentationStyle {
            case .plain:
                custodialBalanceView.layer.borderColor = Color.clear.cgColor
                custodialBalanceViewWidthConstraint.constant = UIScreen.main.bounds.width
            case .border:
                custodialBalanceView.layer.borderColor = Color.lightBorder.cgColor
                custodialBalanceViewWidthConstraint.constant = 320
            }
        }
    }
    
    private var custodialBalanceViewWidthConstraint: NSLayoutConstraint!
    private let custodialBalanceView: FiatCustodialBalanceView
        
    // MARK: - Setup

    override init(frame: CGRect) {
        custodialBalanceView = FiatCustodialBalanceView()
        custodialBalanceView.clipsToBounds = true
        custodialBalanceView.layer.cornerRadius = 16
        custodialBalanceView.layer.borderWidth = 1.0
        super.init(frame: frame)
        contentView.addSubview(custodialBalanceView)
        custodialBalanceView.layoutToSuperview(axis: .vertical)
        custodialBalanceView.layoutToSuperview(axis: .horizontal)
        custodialBalanceViewWidthConstraint = custodialBalanceView.layout(dimension: .width, to: UIScreen.main.bounds.width)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        presenter = nil
        super.prepareForReuse()
    }
}
