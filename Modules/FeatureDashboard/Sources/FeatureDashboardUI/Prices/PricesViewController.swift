// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxDataSources
import RxRelay
import RxSwift
import ToolKit

final class PricesViewController: BaseScreenViewController {

    // MARK: - Private Types

    private typealias RxDataSource = RxTableViewSectionedAnimatedDataSource<PricesViewModel>

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()
    private let presenter: PricesScreenPresenter
    private let tableView = UITableView()
    private let searchBar = UISearchBar()

    // MARK: - Setup

    init(presenter: PricesScreenPresenter = .init()) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        presenter.setup()
        tableView.reloadData()
        presenter.refreshRelay.accept(())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = false
    }

    // MARK: - Setup

    private func setupTableView() {
        view.addSubview(tableView)
        view.addSubview(searchBar)
        searchBar.searchBarStyle = .minimal
        searchBar.layoutToSuperview(axis: .horizontal, offset: 12)
        tableView.layoutToSuperview(axis: .horizontal)
        searchBar.layoutToSuperview(.top)
        searchBar.layout(edge: .bottom, to: .top, of: tableView)
        tableView.layoutToSuperview(.bottom, usesSafeAreaLayoutGuide: true)
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorColor = .clear
        tableView.keyboardDismissMode = .onDrag

        tableView.register(LabelTableViewCell.self, forCellReuseIdentifier: LabelTableViewCell.identifier)
        tableView.register(PricesTableViewCell.self, forCellReuseIdentifier: PricesTableViewCell.identifier)

        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.rx
            .controlEvent(.valueChanged)
            .bind(to: presenter.refreshRelay)
            .disposed(by: disposeBag)
        refreshControl.rx
            .controlEvent(.valueChanged)
            .map { false }
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)

        searchBar.rx.text
            .map { $0 ?? "" }
            .asObservable()
            .bind(to: presenter.searchRelay)
            .disposed(by: disposeBag)

        let dataSource = RxDataSource(
            animationConfiguration: .init(insertAnimation: .fade, reloadAnimation: .fade, deleteAnimation: .fade),
            configureCell: { _, tableView, indexPath, item in
                switch item {
                case .emptyState(let content):
                    let cell = tableView.dequeue(LabelTableViewCell.self, for: indexPath)
                    cell.content = content
                    cell.selectionStyle = .none
                    return cell
                case .currency(_, let presenter):
                    let cell = tableView.dequeue(PricesTableViewCell.self, for: indexPath)
                    cell.presenter = presenter()
                    return cell
                }
            }
        )

        tableView.rx.modelSelected(PricesCellType.self)
            .bindAndCatch(weak: self) { (self, model) in
                switch model {
                case .emptyState:
                    break
                case .currency(let cryptoCurrency, _):
                    self.presenter.router.showDetailsScreen(for: cryptoCurrency)
                }
            }
            .disposed(by: disposeBag)

        presenter.sections
            .observeOn(MainScheduler.asyncInstance)
            .bindAndCatch(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    // MARK: - Navigation

    override func navigationBarLeadingButtonPressed() {
        presenter.navigationBarLeadingButtonPressed()
    }
}
