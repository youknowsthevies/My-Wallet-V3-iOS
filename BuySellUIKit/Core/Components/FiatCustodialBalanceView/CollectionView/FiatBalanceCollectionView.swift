//
//  FiatBalanceCollectionView.swift
//  PlatformUIKit
//
//  Created by Daniel on 13/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import UIKit
import PlatformUIKit
import RxSwift
import RxRelay

final class FiatBalanceCollectionView: UICollectionView {
    
    // MARK: - Types
    
    public class CollectionViewFlowLayout: UICollectionViewFlowLayout {
        override init() {
            super.init()
            estimatedItemSize = CGSize(width: 256, height: 80)
            minimumInteritemSpacing = 0
            minimumLineSpacing = 16
            scrollDirection = .horizontal
            sectionInset = UIEdgeInsets(top: 0, left: Spacing.outer, bottom: 0, right: Spacing.outer)
        }

        @available(*, unavailable)
        required init?(coder aDecoder: NSCoder) { nil }
    }
   
    // MARK: - Injected
   
    public var presenter: FiatBalanceCollectionViewPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let presenter = presenter else { return }
            presenter.presenters
                .drive(rx.items(
                    cellIdentifier: FiatCustodialBalanceCollectionViewCell.objectName,
                    cellType: FiatCustodialBalanceCollectionViewCell.self),
                    curriedArgument: { _, presenter, cell in
                        cell.presenter = presenter
                    }
               )
               .disposed(by: disposeBag)
            
            rx.modelSelected(FiatCustodialBalanceViewPresenter.self)
                .subscribe(onNext: {
                    presenter.selected(currencyType: $0.currencyType)
                })
                .disposed(by: disposeBag)
        }
    }

    public let collectionViewFlowLayout: CollectionViewFlowLayout
    
    // MARK: - Private Properties
    
    private var disposeBag = DisposeBag()
   
    // MARK: - Lifecycle
   
    public init() {
        let collectionViewFlowLayout = CollectionViewFlowLayout()
        self.collectionViewFlowLayout = collectionViewFlowLayout
        super.init(frame: UIScreen.main.bounds, collectionViewLayout: collectionViewFlowLayout)
        backgroundColor = .clear
        isPagingEnabled = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentInsetAdjustmentBehavior = .never
        register(FiatCustodialBalanceCollectionViewCell.self)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) { nil }
}
