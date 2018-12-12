//
//  KYCTiersViewController.swift
//  Blockchain
//
//  Created by Alex McGregor on 12/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import UIKit

class KYCTiersViewController: UIViewController {
    
    // MARK: Private IBOutlets
    
    @IBOutlet fileprivate var layout: UICollectionViewFlowLayout!
    @IBOutlet fileprivate var collectionView: UICollectionView!
    
    // MARK: Private Properties
    
    fileprivate var layoutAttributes: LayoutAttributes = .tiersOverview
    
    // MARK: Public Properties
    
    var pageModel: KYCTiersPageModel = .demo
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        registerCells()
        registerSupplementaryViews()
        collectionView.reloadData()
    }
    
    fileprivate func setupLayout() {
        guard let layout = layout else { return }
        
        layout.sectionInset = layoutAttributes.sectionInsets
        layout.minimumLineSpacing = layoutAttributes.minimumLineSpacing
        layout.minimumInteritemSpacing = layoutAttributes.minimumInterItemSpacing
    }
    
    fileprivate func registerCells() {
        guard let collection = collectionView else { return }
        collection.delegate = self
        collection.dataSource = self
        
        let nib = UINib(nibName: KYCTierCell.identifier, bundle: nil)
        collection.register(nib, forCellWithReuseIdentifier: KYCTierCell.identifier)
    }
    
    fileprivate func registerSupplementaryViews() {
        guard let collection = collectionView else { return }
        let header = UINib(nibName: KYCTiersHeaderView.identifier, bundle: nil)
        let footer = UINib(nibName: KYCTiersFooterView.identifier, bundle: nil)
        collection.register(
            header,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: KYCTiersHeaderView.identifier
        )
        collection.register(
            footer,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: KYCTiersFooterView.identifier
        )
    }
}

extension KYCTiersViewController: KYCTiersHeaderViewDelegate {
    func headerView(_ view: KYCTiersHeaderView, actionTapped: KYCTiersHeaderViewModel.Action) {
        switch actionTapped {
        case .swapNow:
            break
        case .contactSupport:
            break
        case .learnMore:
            break
        }
    }
    
    func dismissButtonTapped(_ view: KYCTiersHeaderView) {
        dismiss(animated: true, completion: nil)
    }
}

extension KYCTiersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageModel.cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = pageModel.cells[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: KYCTierCell.identifier,
            for: indexPath) as? KYCTierCell else {
                return UICollectionViewCell()
        }
        cell.configure(with: item)
        return cell
    }
}

extension KYCTiersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let model = pageModel.cells[indexPath.row]
        let width = collectionView.bounds.size.width - layoutAttributes.sectionInsets.left - layoutAttributes.sectionInsets.right
        let height = KYCTierCell.heightForProposedWidth(width, model: model)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind
        kind: String,
        at indexPath: IndexPath
        ) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            guard let disclaimer = pageModel.disclaimer else { return UICollectionReusableView() }
            guard let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionFooter,
                withReuseIdentifier: KYCTiersFooterView.identifier,
                for: indexPath
                ) as? KYCTiersFooterView else { return UICollectionReusableView() }
            footer.configure(with: disclaimer)
            return footer
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: KYCTiersHeaderView.identifier,
                for: indexPath
                ) as? KYCTiersHeaderView else { return UICollectionReusableView() }
            header.configure(with: pageModel.header)
            header.delegate = self
            return header
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
        ) -> CGSize {
        let height = KYCTiersHeaderView.estimatedHeight(
            for: collectionView.bounds.width,
            model: pageModel.header
        )
        let width = collectionView.bounds.size.width - layoutAttributes.sectionInsets.left - layoutAttributes.sectionInsets.right
        return CGSize(width: width, height: height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
        ) -> CGSize {
        guard let disclaimer = pageModel.disclaimer else { return .zero }
        let height = KYCTiersFooterView.estimatedHeight(
            for: disclaimer,
            width: collectionView.bounds.width
        )
        let width = collectionView.bounds.size.width - layoutAttributes.sectionInsets.left - layoutAttributes.sectionInsets.right
        return CGSize(width: width, height: height)
    }
}
