//
//  CheckoutScreenViewController.swift
//  Blockchain
//
//  Created by AlexM on 1/23/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

final class CheckoutScreenViewController: BaseScreenViewController {
    
    // MARK: - Private IBOutlets
    
    @IBOutlet private var tableView: SelfSizingTableView!
    @IBOutlet private var buyButtonView: ButtonView!
    @IBOutlet private var cancelButtonView: ButtonView!
    
    // MARK: - Injected
    
    private let presenter: CheckoutScreenPresenter

    // MARK: - Setup
    
    init(using presenter: CheckoutScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: CheckoutScreenViewController.objectName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
                
        buyButtonView.viewModel = presenter.buyButtonViewModel
        cancelButtonView.viewModel = presenter.cancelButtonViewModel
        
        presenter.viewDidLoad()
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 65
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorColor = .clear
        tableView.registerNibCell(LineItemTableViewCell.objectName)
        tableView.register(NoticeTableViewCell.self)
        tableView.registerNibCell(CheckoutSummaryTableViewCell.objectName)
        tableView.registerNibCell(SeparatorTableViewCell.objectName)
    }
    
    private func setupNavigationBar() {
        titleViewStyle = presenter.titleView
        set(barStyle: presenter.barStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: presenter.trailingButton)
    }
    
    // MARK: - Navigation
    
    override func navigationBarLeadingButtonPressed() {
        presenter.previous()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension CheckoutScreenViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return presenter.cellArrangement.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        let type = presenter.cellArrangement[indexPath.row]
        switch type {
        case .disclaimer:
            cell = disclaimerCell(for: indexPath)
        case .lineItem(let lineType):
            cell = lineItemCell(for: indexPath, type: lineType)
        case .separator:
            cell = separatorCell(for: indexPath)
        case .summary:
            cell = summaryCell(for: indexPath)
        case .termsAndConditions:
            break
        }
        return cell
    }
        
    // MARK: - Accessors
    
    private func separatorCell(for indexPath: IndexPath) -> SeparatorTableViewCell {
        let cell = tableView.dequeue(SeparatorTableViewCell.self, for: indexPath)
        return cell
    }
    
    private func lineItemCell(for indexPath: IndexPath, type: CheckoutCellType.LineItemType) -> LineItemTableViewCell {
        let cell = tableView.dequeue(LineItemTableViewCell.self, for: indexPath)
        switch type {
        case .date:
            cell.presenter = presenter.dateLineItemCellPresenter
        case .totalCost:
            cell.presenter = presenter.totalCostLineItemCellPresenter
        case .estimatedAmount:
            cell.presenter = presenter.estimatedLineItemCellPresenter
        case .buyingFee:
            cell.presenter = presenter.buyingFeeLineItemCellPresenter
        case .paymentMethod:
            cell.presenter = presenter.paymentMethodLineItemCellPresenter
        case .paymentAccountField:
            break
        }
        return cell
    }
    
    private func summaryCell(for indexPath: IndexPath) -> CheckoutSummaryTableViewCell {
        let cell = tableView.dequeue(CheckoutSummaryTableViewCell.self, for: indexPath)
        cell.content = presenter.summaryLabelContent
        return cell
    }
    
    private func disclaimerCell(for indexPath: IndexPath) -> NoticeTableViewCell {
        let cell = tableView.dequeue(NoticeTableViewCell.self, for: indexPath)
        cell.viewModel = presenter.noticeViewModel
        return cell
    }
}

