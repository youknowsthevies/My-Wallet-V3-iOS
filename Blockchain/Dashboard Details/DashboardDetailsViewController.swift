//
//  DashboardDetailsViewController.swift
//  Blockchain
//
//  Created by AlexM on 11/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import RxSwift

final class DashboardDetailsViewController: BaseScreenViewController {
    
    // MARK: - Private Properties
    
    private let disposeBag = DisposeBag()

    // MARK: - IBOutlets
    
    @IBOutlet private var tableView: SelfSizingTableView!
    
    // MARK: - Injected
    
    private let presenter: DashboardDetailsScreenPresenter

    // MARK: - Setup
    
    init(using presenter: DashboardDetailsScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: DashboardDetailsViewController.objectName, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
        
        if #available(iOS 13.0, *) {
            navigationController?.setNavigationBarHidden(true, animated: false)
        } else {
            navigationController?.setNavigationBarHidden(false, animated: false)
        }
        
        presenter.setup()
        presenter.refresh()
        presenter.collectionAction
            .emit(onNext: { [weak self] action in
                self?.execute(action: action)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 312
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerNibCell(MultiActionTableViewCell.self)
        tableView.registerNibCell(PriceAlertTableViewCell.self)
        tableView.registerNibCell(AssetLineChartTableViewCell.self)
        tableView.registerNibCell(CurrentBalanceTableViewCell.self)
        tableView.separatorColor = .clear
        presenter.isScrollEnabled
            .drive(tableView.rx.isScrollEnabled)
            .disposed(by: disposeBag)
        tableView.rx.itemSelected
            .map { self.presenter.cellArrangement[$0.row] }
            .bind(to: presenter.presenterSelectionRelay)
            .disposed(by: disposeBag)
    }
    
    private func setupNavigationBar() {
        set(barStyle: presenter.barStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: presenter.trailingButton)
        titleViewStyle = presenter.titleView
    }
    
    // MARK: - Actions
    
    private func execute(action: DashboardDetailsCollectionAction) {
        switch action {
        case .custodial(let custodialAction):
            execute(custodialAction: custodialAction)
        }
    }
    
    private func execute(custodialAction: CustodialCellTypeAction) {
        switch custodialAction {
        case .none:
            break
        case .show:
            let row = presenter.indexByCellType[.balance(.custodial)]!
            tableView.insertRows(at: [.init(row: row, section: 0)], with: .automatic)
        }
    }
    
    private lazy var sheetPresenter: BottomSheetPresenting = {
        return BottomSheetPresenting(ignoresBackroundTouches: false)
    }()
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension DashboardDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return presenter.cellCount
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let type = presenter.cellArrangement[indexPath.row]
        switch type {
        case .sendRequest:
            cell = multiActionCell(for: indexPath, presenter: presenter.sendRequestPresenter)
        case .priceAlert:
            cell = priceAlertCell(for: indexPath)
        case .balance(let balanceType):
            cell = currentBalanceCell(for: indexPath, type: balanceType)
        case .chart:
            cell = assetLineChartCell(for: indexPath, presenter: presenter.lineChartCellPresenter)
        }
        cell.selectionStyle = .none
        return cell
    }
        
    // MARK: - Accessors
    
    private func priceAlertCell(for indexPath: IndexPath) -> PriceAlertTableViewCell {
        let cell = tableView.dequeue(PriceAlertTableViewCell.self, for: indexPath)
        cell.currency = presenter.currency
        return cell
    }
    
    private func multiActionCell(for indexPath: IndexPath, presenter: MultiActionViewPresenting) -> MultiActionTableViewCell {
        let cell = tableView.dequeue(MultiActionTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }
    
    private func currentBalanceCell(for indexPath: IndexPath, type: BalanceType) -> UITableViewCell {
        let cell = tableView.dequeue(CurrentBalanceTableViewCell.self, for: indexPath)
        switch type {
        case .custodial:
            cell.presenter = presenter.custodyAssetBalanceViewPresenter
        case .nonCustodial:
            cell.presenter = presenter.balanceCellPresenter
        }
        cell.currency = presenter.currency
        return cell
    }
    
    private func assetLineChartCell(for indexPath: IndexPath, presenter: AssetLineChartTableViewCellPresenter) -> AssetLineChartTableViewCell {
        let cell = tableView.dequeue(AssetLineChartTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }
}
