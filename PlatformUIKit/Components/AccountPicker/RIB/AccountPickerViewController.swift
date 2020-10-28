//
//  AccountPickerViewController.swift
//  PlatformUIKit
//
//  Created by Paulo on 21/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RIBs
import RxCocoa
import RxDataSources
import RxRelay
import RxSwift

protocol AccountPickerViewControllable: ViewControllable {
    func connect(state: Driver<AccountPickerPresenter.State>) -> Driver<AccountPickerInteractor.Effects>
}

final class AccountPickerViewController: BaseScreenViewController, AccountPickerViewControllable {

    // MARK: - Types

    private typealias RxDataSource = RxTableViewSectionedReloadDataSource<AccountPickerSectionViewModel>

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let headerBuilder = AccountPickerHeaderBuilder()
    private let headerRelay = BehaviorRelay<AccountPickerHeaderType>(value: .none)
    private lazy var dataSource: RxDataSource = {
        RxDataSource(configureCell: { [weak self] dataSource, tableView, indexPath, item in
            guard let self = self else { return UITableViewCell() }
            let cell: UITableViewCell
            switch item.presenter {
            case .accountGroup(let presenter):
                cell = self.totalBalanceCell(for: indexPath, presenter: presenter)
            case .singleAccount(let presenter):
                cell = self.balanceCell(for: indexPath, presenter: presenter)
            }
            cell.selectionStyle = .none
            return cell
        })
    }()
    private lazy var setupTableView: Void = {
        tableView.delegate = self
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.separatorColor = .clear
        tableView.alwaysBounceVertical = true
        tableView.register(CurrentBalanceTableViewCell.self)
        tableView.registerNibCell(AccountGroupBalanceTableViewCell.self)
    }()

    // MARK: - Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        _ = setupTableView
        view.addSubview(tableView)
        tableView.layoutToSuperview(.top, .bottom, .leading, .trailing)
    }

    // MARK: - Methods
    func connect(state: Driver<AccountPickerPresenter.State>) -> Driver<AccountPickerInteractor.Effects> {
        disposeBag = DisposeBag()
        // TODO: IOS-3987 Deal with view life cycle in a different way.
        _ = setupTableView
        state
            .map(\.navigationModel)
            .drive(weak: self) { (self, model) in
                self.titleViewStyle = model.titleViewStyle
                self.set(barStyle: model.barStyle,
                         leadingButtonStyle: model.leadingButton,
                         trailingButtonStyle: model.trailingButton)
            }
            .disposed(by: disposeBag)

        state.map(\.headerModel)
            .drive(headerRelay)
            .disposed(by: disposeBag)

        state.map(\.sections)
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        let modelSelected = tableView.rx.modelSelected(AccountPickerCellItem.self)
            .map { AccountPickerInteractor.Effects.select($0.account) }
            .asDriver(onErrorJustReturn: .none)

        return modelSelected
    }

    // MARK: - Private Methods

    private func balanceCell(for indexPath: IndexPath, presenter: CurrentBalanceCellPresenting) -> UITableViewCell {
        let cell = tableView.dequeue(CurrentBalanceTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func totalBalanceCell(for indexPath: IndexPath, presenter: AccountGroupBalanceCellPresenter) -> AccountGroupBalanceTableViewCell {
        let cell = tableView.dequeue(AccountGroupBalanceTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }
}

extension AccountPickerViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else { return nil }
        return headerBuilder.view(for: headerRelay.value, fittingWidth: view.bounds.width)
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section == 0 else { return 0 }
        return headerBuilder.defaultHeight(for: headerRelay.value)
    }
}
