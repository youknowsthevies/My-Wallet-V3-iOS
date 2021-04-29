// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxDataSources
import RxSwift

public final class WalletActionScreenViewController: UIViewController {
    
    // MARK: - Private Types
    
    private typealias RxDataSource = RxTableViewSectionedAnimatedDataSource<WalletActionItemsSectionViewModel>
    
    // MARK: - Private Properties
    
    private let disposeBag = DisposeBag()

    // MARK: - IBOutlets
    
    private let tableView = SelfSizingTableView()

    // MARK: - Injected
    
    private let presenter: WalletActionScreenPresenting

    // MARK: - Setup
    
    public init(using presenter: WalletActionScreenPresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle
    
    public override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        tableView.fillSuperview(usesSafeAreaLayoutGuide: true)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 85
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(CurrentBalanceTableViewCell.self)
        tableView.register(DefaultWalletActionTableViewCell.self)
        tableView.separatorInset = .zero
        tableView.separatorColor = .lightBorder
        
        let dataSource = RxDataSource(configureCell: { [weak self] _, _, indexPath, item in
            guard let self = self else { return UITableViewCell() }
            let cell: UITableViewCell
            
            switch item {
            case .balance(let presenter):
                cell = self.currentBalanceCell(for: indexPath, presenter: presenter)
            case .default(let presenter):
                cell = self.defaultActionCell(for: indexPath, presenter: presenter)
            }
            cell.selectionStyle = .none
            return cell
        })
        
        presenter.sections
            .bindAndCatch(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx
            .modelSelected(WalletActionCellType.self)
            .bindAndCatch(to: presenter.selectionRelay)
            .disposed(by: disposeBag)
    }
}

extension WalletActionScreenViewController {
        
    // MARK: - Accessors
    
    private func currentBalanceCell(for indexPath: IndexPath, presenter: CurrentBalanceCellPresenter) -> UITableViewCell {
        let cell = tableView.dequeue(CurrentBalanceTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }
    
    private func defaultActionCell(for indexPath: IndexPath, presenter: DefaultWalletActionCellPresenter) -> UITableViewCell {
        let cell = tableView.dequeue(DefaultWalletActionTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }
}
