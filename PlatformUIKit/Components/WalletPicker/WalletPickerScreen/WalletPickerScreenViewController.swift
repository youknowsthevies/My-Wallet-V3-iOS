//
//  WalletPickerScreenViewController.swift
//  Blockchain
//
//  Created by Alex McGregor on 5/5/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import RxCocoa
import RxDataSources
import RxSwift
import ToolKit

public final class WalletPickerScreenViewController: BaseScreenViewController {
    
    // MARK: - Types
    
    private typealias RxDataSource = RxTableViewSectionedReloadDataSource<WalletPickerSectionViewModel>
    
    // MARK: - Private IBOutlets
    
    private var tableView: UITableView!
    
    // MARK: - Private Properties
    
    private let presenter: WalletPickerScreenPresenter
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(presenter: WalletPickerScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizationConstants.settings
        setupTableView()
        setupNavigationBar()
    }
    
    // MARK: - Private Functions
    
    private func setupNavigationBar() {
        titleViewStyle = presenter.titleViewStyle
        set(barStyle: presenter.barStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: presenter.trailingButton
        )
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.separatorColor = .clear
        tableView.alwaysBounceVertical = true
        tableView.registerNibCell(CurrentBalanceTableViewCell.self)
        tableView.registerNibCell(WalletBalanceTableViewCell.self)
        view.addSubview(tableView)
        tableView.layoutToSuperview(.top, .bottom, .leading, .trailing)
        
        let dataSource = RxDataSource(configureCell: { [weak self] _, _, indexPath, item in
            guard let self = self else { return UITableViewCell() }
            let cell: UITableViewCell
            switch item {
            case .balance(let balanceType):
                cell = self.balanceCell(for: indexPath, presenter: balanceType.presenter)
            case .total(let presenter):
                cell = self.totalBalanceCell(for: indexPath, presenter: presenter)
            }
            cell.selectionStyle = .none
            return cell
        })
        
        presenter.sectionObservable
            .bindAndCatch(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(WalletPickerCellItem.self)
            .bindAndCatch(weak: self) { (self, model) in
                switch model {
                case .total:
                    self.presenter.record(selection: .all)
                case .balance(let balanceType):
                    switch balanceType {
                    case .custodial(let presenter):
                        self.presenter.record(selection: .custodial(presenter.currency))
                    case .nonCustodial(let presenter):
                        self.presenter.record(selection: .nonCustodial(presenter.currency))
                    }
                }
                self.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension WalletPickerScreenViewController: UITableViewDelegate {
    private func balanceCell(for indexPath: IndexPath, presenter: CurrentBalanceCellPresenter) -> CurrentBalanceTableViewCell {
        let cell = tableView.dequeue(CurrentBalanceTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }
    
    private func totalBalanceCell(for indexPath: IndexPath, presenter: WalletBalanceCellPresenter) -> WalletBalanceTableViewCell {
        let cell = tableView.dequeue(WalletBalanceTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }
}

