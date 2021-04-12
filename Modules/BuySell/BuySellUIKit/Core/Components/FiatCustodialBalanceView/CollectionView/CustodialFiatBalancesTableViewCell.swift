//
//  CustodialFiatBalancesTableViewCell.swift
//  PlatformUIKit
//
//  Created by Daniel on 13/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

/// A cell that contains a horizontal collection view with the fiat balances
public final class FiatCustodialBalancesTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    public var presenter: FiatBalanceCollectionViewPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            collectionView.presenter = presenter
            presenter?.presenters
                .map { $0.count > 1 }
                .drive(weak: self) { (self, hasMultipleBalances) in
                    if hasMultipleBalances {
                        self.collectionView.collectionViewFlowLayout.minimumLineSpacing = Spacing.inner
                        self.collectionView.collectionViewFlowLayout.minimumInteritemSpacing = Spacing.inner
                        self.collectionView.collectionViewFlowLayout.sectionInset = UIEdgeInsets(
                            top: 0,
                            left: Spacing.outer,
                            bottom: 0,
                            right: Spacing.outer
                        )
                        self.separatorView.isHidden = true
                    } else {
                        self.collectionView.collectionViewFlowLayout.minimumLineSpacing = 0
                        self.collectionView.collectionViewFlowLayout.minimumInteritemSpacing = 0
                        self.collectionView.collectionViewFlowLayout.sectionInset = .zero
                        self.separatorView.isHidden = false
                    }
                }
                .disposed(by: disposeBag)
        }
    }

    private var disposeBag = DisposeBag()
    private let collectionView: FiatBalanceCollectionView
    private let separatorView = UIView()
    
    // MARK: - Lifecycle
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        collectionView = FiatBalanceCollectionView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(collectionView)
        collectionView.fillSuperview()
        collectionView.layout(dimension: .height, to: 112, priority: .penultimateHigh)
        
        contentView.addSubview(separatorView)
        separatorView.backgroundColor = .lightBorder
        separatorView.layoutToSuperview(.leading, .trailing, .bottom)
        separatorView.layout(dimension: .height, to: 1)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) { nil }
    
    public override func prepareForReuse() {
        presenter = nil
        super.prepareForReuse()
    }
}
