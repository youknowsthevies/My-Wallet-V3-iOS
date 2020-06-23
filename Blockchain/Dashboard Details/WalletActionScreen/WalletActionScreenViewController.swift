//
//  CustodyActionScreenViewController.swift
//  Blockchain
//
//  Created by AlexM on 1/31/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxCocoa
import RxSwift

final class WalletActionScreenViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let disposeBag = DisposeBag()

    // MARK: - IBOutlets
    
    @IBOutlet private var swapButtonView: ButtonView!
    @IBOutlet private var viewActivityButtonView: ButtonView!
    @IBOutlet private var sendToWallet: ButtonView!
    @IBOutlet private var tableView: SelfSizingTableView!
    @IBOutlet private var spacerView: UIView!

    // MARK: - Injected
    
    private let presenter: WalletActionScreenPresenting

    // MARK: - Setup
    
    init(using presenter: WalletActionScreenPresenting) {
        self.presenter = presenter
        super.init(nibName: WalletActionScreenViewController.objectName, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        sendToWallet.viewModel = presenter.sendToWalletViewModel
        viewActivityButtonView.viewModel = presenter.activityButtonViewModel
        swapButtonView.viewModel = presenter.swapButtonViewModel

        Driver
            .combineLatest(
                presenter.sendToWalletVisibility,
                presenter.activityButtonVisibility,
                presenter.swapButtonVisibility
            )
            .map { $0.isHidden && $1.isHidden && $2.isHidden }
            .map { !$0 }
            .drive(spacerView.rx.isHidden)
            .disposed(by: disposeBag)

        presenter.sendToWalletVisibility
            .map { $0.isHidden }
            .drive(sendToWallet.rx.isHidden)
            .disposed(by: disposeBag)
        
        presenter.activityButtonVisibility
            .map { $0.isHidden }
            .drive(viewActivityButtonView.rx.isHidden)
            .disposed(by: disposeBag)
        
        presenter.swapButtonVisibility
            .map { $0.isHidden }
            .drive(swapButtonView.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 85
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerNibCell(CurrentBalanceTableViewCell.self)
        tableView.separatorColor = .clear
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension WalletActionScreenViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        presenter.cellCount
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let type = presenter.cellArrangement[indexPath.row]
        switch type {
        case .balance:
            cell = currentBalanceCell(for: indexPath)
        }
        cell.selectionStyle = .none
        return cell
    }
        
    // MARK: - Accessors
    
    private func currentBalanceCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(CurrentBalanceTableViewCell.self, for: indexPath)
        cell.presenter = presenter.assetBalanceViewPresenter
        return cell
    }
}
