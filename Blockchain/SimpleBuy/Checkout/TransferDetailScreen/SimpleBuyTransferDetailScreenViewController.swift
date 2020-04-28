//
//  SimpleBuyTransferDetailScreenViewController.swift
//  Blockchain
//
//  Created by AlexM on 1/28/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxSwift

final class SimpleBuyTransferDetailScreenViewController: BaseTableViewController {
    
    // MARK: - Injected
    
    private let presenter: SimpleBuyTransferDetailScreenPresenter
    
    // MARK: - Private Properties
    
    private let disposeBag = DisposeBag()

    // MARK: - Setup
    
    init(using presenter: SimpleBuyTransferDetailScreenPresenter) {
        self.presenter = presenter
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
        continueButtonView.viewModel = presenter.continueButtonViewModel
        
        /// Add cancellation option if it should be available to the end user
        if let viewModel = presenter.cancelButtonViewModel {
            let cancelButton = ButtonView()
            cancelButton.viewModel = viewModel
            buttonStackView.addArrangedSubview(cancelButton)
            cancelButton.layout(dimension: .height, to: 48)
        }
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 65
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorColor = .clear
        tableView.register(NoticeTableViewCell.self)
        tableView.register(InteractableTextTableViewCell.self)
        tableView.registerNibCell(LineItemTableViewCell.objectName)
        tableView.registerNibCell(CheckoutSummaryTableViewCell.objectName)
        tableView.registerNibCell(SeparatorTableViewCell.objectName)
    }
    
    private func setupNavigationBar() {
        set(barStyle: presenter.barStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: presenter.trailingButton)
        titleViewStyle = presenter.titleView
    }
    
    // MARK: - Navigation
    
    override func navigationBarLeadingButtonPressed() {
        presenter.previous()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SimpleBuyTransferDetailScreenViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.didSelectItem(with: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return presenter.cellArrangement.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let type = presenter.cellArrangement[indexPath.row]
        switch type {
        case .disclaimer:
            cell = disclaimerCell(for: indexPath)
        case .termsAndConditions:
            cell = interactableTextCell(for: indexPath)
        case .lineItem(let lineType):
            cell = lineItemCell(for: indexPath, type: lineType)
        case .separator:
            cell = separatorCell(for: indexPath)
        case .summary:
            cell = summaryCell(for: indexPath)
        }
        return cell
    }
        
    // MARK: - Accessors
    
    private func interactableTextCell(for indexPath: IndexPath) -> InteractableTextTableViewCell {
        let cell = tableView.dequeue(InteractableTextTableViewCell.self, for: indexPath)
        cell.contentInset = UIEdgeInsets(horizontal: 24, vertical: 0)
        cell.viewModel = presenter.termsViewModel
        return cell
    }
    
    private func separatorCell(for indexPath: IndexPath) -> SeparatorTableViewCell {
        let cell = tableView.dequeue(SeparatorTableViewCell.self, for: indexPath)
        return cell
    }
    
    private func lineItemCell(for indexPath: IndexPath, type: CheckoutCellType.LineItemType) -> LineItemTableViewCell {
        let cell = tableView.dequeue(LineItemTableViewCell.self, for: indexPath)
        cell.presenter = presenter.presentersByCellType[type]
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
