// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxDataSources
import RxRelay
import RxSwift
import ToolKit

/// A view controller that displays the dashboard
public final class DashboardViewController: BaseScreenViewController {

    // MARK: - Private Types

    private typealias RxDataSource = RxTableViewSectionedAnimatedDataSource<DashboardViewModel>

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()
    private let fiatBalanceCellProvider: FiatBalanceCellProviding
    private let presenter: DashboardScreenPresenter
    private let tableView = UITableView()
    private var refreshControl: UIRefreshControl!

    // MARK: - Setup

    public convenience init() {
        self.init(
            fiatBalanceCellProvider: resolve(),
            presenter: DashboardScreenPresenter()
        )
    }

    init(
        fiatBalanceCellProvider: FiatBalanceCellProviding,
        presenter: DashboardScreenPresenter
    ) {
        self.fiatBalanceCellProvider = fiatBalanceCellProvider
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        unimplemented()
    }

    // MARK: - Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupTableView()
        presenter.setup()
        tableView.reloadData()
        presenter.refresh()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = false
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        set(
            barStyle: .lightContent(),
            leadingButtonStyle: .drawer,
            trailingButtonStyle: .none
        )
        titleViewStyle = .text(value: LocalizationConstants.DashboardScreen.title)
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.layoutToSuperview(axis: .horizontal, usesSafeAreaLayoutGuide: true)
        tableView.layoutToSuperview(axis: .vertical, usesSafeAreaLayoutGuide: true)
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(AnnouncementTableViewCell.self)
        fiatBalanceCellProvider.registerFiatBalanceCell(for: tableView)
        tableView.register(NoticeTableViewCell.self)
        tableView.registerNibCell(TotalBalanceTableViewCell.self, in: TotalBalanceTableViewCell.bundle)
        tableView.registerNibCell(HistoricalBalanceTableViewCell.self, in: HistoricalBalanceTableViewCell.bundle)
        tableView.separatorColor = .clear

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        tableView.refreshControl = refreshControl
        let dataSource = RxDataSource(
            animationConfiguration: .init(insertAnimation: .fade, reloadAnimation: .fade, deleteAnimation: .fade),
            configureCell: { [weak self] _, _, indexPath, item in
                guard let self = self else { return UITableViewCell() }
                let cell: UITableViewCell

                switch item {
                case .announcement:
                    cell = self.announcementCell(for: indexPath)
                case .fiatCustodialBalances:
                    cell = self.fiatCustodialBalancesCell(for: indexPath)
                case .totalBalance:
                    cell = self.balanceCell(for: indexPath)
                case .crypto(let currency):
                    cell = self.assetCell(for: indexPath, currency: currency)
                case .notice:
                    cell = self.noticeCell(for: indexPath)
                }
                cell.selectionStyle = .none
                return cell
            }
        )

        tableView.rx.modelSelected(DashboardCellType.self)
            .bindAndCatch(weak: self) { (self, model) in
                switch model {
                case .announcement,
                     .notice,
                     .totalBalance,
                     .fiatCustodialBalances:
                    break
                case .crypto(let currency):
                    self.presenter.router.showDetailsScreen(for: currency)
                }
            }
            .disposed(by: disposeBag)

        presenter.sections
            .observeOn(MainScheduler.asyncInstance)
            .bindAndCatch(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    // MARK: - Navigation

    override public func navigationBarLeadingButtonPressed() {
        presenter.navigationBarLeadingButtonPressed()
    }

    // MARK: - UITableView Refresh

    @objc private func refresh() {
        presenter.refresh()
        refreshControl.endRefreshing()
    }

    // MARK: - Cells

    private func fiatCustodialBalancesCell(for indexPath: IndexPath) -> UITableViewCell {
        fiatBalanceCellProvider.dequeueReusableFiatBalanceCell(
            for: tableView,
            indexPath: indexPath,
            presenter: presenter.fiatBalanceCollectionViewPresenter
        )
    }

    private func announcementCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(AnnouncementTableViewCell.self, for: indexPath)
        cell.viewModel = presenter.announcementCardViewModel
        return cell
    }

    private func balanceCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(TotalBalanceTableViewCell.self, for: indexPath)
        cell.presenter = presenter.totalBalancePresenter
        return cell
    }

    private func assetCell(for indexPath: IndexPath, currency: CryptoCurrency) -> UITableViewCell {
        let cell = tableView.dequeue(HistoricalBalanceTableViewCell.self, for: indexPath)
        cell.presenter = presenter.historicalBalancePresenter(by: currency)
        return cell
    }

    private func noticeCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(NoticeTableViewCell.self, for: indexPath)
        cell.viewModel = presenter.noticeViewModel
        return cell
    }
}
