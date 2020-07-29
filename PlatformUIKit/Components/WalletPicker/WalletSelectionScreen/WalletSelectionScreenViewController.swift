//
//  WalletPickerScreenViewController.swift
//  PlatformUIKit
//
//  Created by Paulo on 28/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import RxCocoa
import RxDataSources
import RxSwift
import ToolKit

public final class WalletSelectionScreenViewController: UIViewController {

    // MARK: - Types

    private typealias RxDataSource = RxTableViewSectionedReloadDataSource<WalletPickerSectionViewModel>

    // MARK: - Private IBOutlets

    private lazy var tableView: UITableView = UITableView(frame: .zero, style: .grouped)

    // MARK: - Private Properties

    private let presenter: WalletSelectionScreenPresenter
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(presenter: WalletSelectionScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    // MARK: - Private Functions

    private func setupTableView() {
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
                        guard case let .crypto(currency) = presenter.currency else { return }
                        self.presenter.record(selection: .custodial(currency))
                    case .nonCustodial(let presenter):
                        guard case let .crypto(currency) = presenter.currency else { return }
                        self.presenter.record(selection: .nonCustodial(currency))
                    }
                }
                self.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
    }

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

