// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RIBs
import RxCocoa
import RxDataSources
import RxRelay
import RxSwift
import ToolKit
import UIKit

public protocol AccountPickerViewControllable: ViewControllable {
    var shouldOverrideNavigationEffects: Bool { get set }

    func connect(state: Driver<AccountPickerPresenter.State>) -> Driver<AccountPickerInteractor.Effects>
}

public final class AccountPickerViewController: BaseScreenViewController, AccountPickerViewControllable {

    // MARK: - Types

    private typealias RxDataSource = RxTableViewSectionedReloadDataSource<AccountPickerSectionViewModel>

    // MARK: - Public Properties

    public var shouldOverrideNavigationEffects: Bool = false

    // MARK: - Private Properties

    /// Store current header view so we can remove it when a new one is going to be displayed.
    private weak var headerView: UIView?
    private var disposeBag = DisposeBag()
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let headerRelay = BehaviorRelay<AccountPickerHeaderBuilder?>(value: nil)
    private let backButtonRelay = PublishRelay<Void>()
    private let closeButtonRelay = PublishRelay<Void>()
    private let searchRelay = PublishRelay<String?>()

    private lazy var dataSource: RxDataSource = {
        RxDataSource(configureCell: { [weak self] _, _, indexPath, item in
            guard let self = self else { return UITableViewCell() }
            let cell: UITableViewCell
            switch item.presenter {
            case .button(let viewModel):
                cell = self.buttonTableViewCell(for: indexPath, viewModel: viewModel)
            case .linkedBankAccount(let presenter):
                cell = self.linkedBankCell(for: indexPath, presenter: presenter)
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
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.separatorColor = .clear
        tableView.alwaysBounceVertical = true
        tableView.keyboardDismissMode = .onDrag
        tableView.register(LinkedBankAccountTableViewCell.self)
        tableView.register(CurrentBalanceTableViewCell.self)
        tableView.registerNibCell(AccountGroupBalanceTableViewCell.self, in: .module)
        tableView.registerNibCell(ButtonsTableViewCell.self, in: .module)
    }()

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { unimplemented() }

    // MARK: - Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        _ = setupTableView
        view.addSubview(tableView)
        tableView.layoutToSuperview(.top, .bottom, .leading, .trailing)
    }

    // MARK: - Methods

    public func connect(state: Driver<AccountPickerPresenter.State>) -> Driver<AccountPickerInteractor.Effects> {
        disposeBag = DisposeBag()
        tableView.delegate = self

        let stateWait: Driver<AccountPickerPresenter.State> =
            rx.viewDidLoad
                .asDriver()
                .flatMap { _ in
                    state
                }

        stateWait
            .map(\.navigationModel)
            .drive(weak: self) { (self, model) in
                self.titleViewStyle = model.titleViewStyle
                self.set(
                    barStyle: model.barStyle,
                    leadingButtonStyle: model.leadingButton,
                    trailingButtonStyle: model.trailingButton
                )
            }
            .disposed(by: disposeBag)

        stateWait.map(\.headerModel)
            .distinctUntilChanged()
            .map(AccountPickerHeaderBuilder.init)
            .drive(headerRelay)
            .disposed(by: disposeBag)

        headerRelay.asDriver()
            .compactMap { $0 }
            .drive(
                onNext: { [weak self] headerBuilder in
                    self?.prepare(headerBuilder: headerBuilder)
                }
            )
            .disposed(by: disposeBag)

        stateWait.map(\.sections)
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        let modelSelected = tableView.rx.modelSelected(AccountPickerCellItem.self)
            .compactMap(\.account)
            .map { AccountPickerInteractor.Effects.select($0) }
            .asDriver(onErrorJustReturn: .none)

        let backButtonEffect = backButtonRelay
            .map { AccountPickerInteractor.Effects.back }
            .asDriverCatchError()

        let closeButtonEffect = closeButtonRelay
            .map { AccountPickerInteractor.Effects.closed }
            .asDriverCatchError()

        let searchEffect = searchRelay
            .distinctUntilChanged()
            .map { AccountPickerInteractor.Effects.filter($0) }
            .asDriverCatchError()

        return .merge(modelSelected, backButtonEffect, closeButtonEffect, searchEffect)
    }

    private func prepare(headerBuilder: AccountPickerHeaderBuilder) {
        guard headerBuilder.isAlwaysVisible else {
            headerView?.removeFromSuperview()
            tableView.contentInset = .zero
            return
        }
        guard let headerBuilder = headerRelay.value else {
            return
        }
        guard let headerView = headerBuilder.headerView(
            fittingWidth: view.bounds.width,
            customHeight: nil
        ) else {
            return
        }
        self.headerView = headerView
        headerView.searchBar?.rx
            .text
            .bind(to: searchRelay)
            .disposed(by: disposeBag)
        headerView.layout(dimension: .height, to: headerBuilder.defaultHeight)
        view.addSubview(headerView)
        headerView.layoutToSuperview(.leading, .top, .trailing)
        tableView.contentInset = UIEdgeInsets(
            top: headerBuilder.defaultHeight,
            left: 0,
            bottom: 0,
            right: 0
        )
    }

    override public func navigationBarLeadingButtonPressed() {
        guard shouldOverrideNavigationEffects else {
            super.navigationBarLeadingButtonPressed()
            return
        }
        switch leadingButtonStyle {
        case .close:
            closeButtonRelay.accept(())
        case .back:
            backButtonRelay.accept(())
        default:
            super.navigationBarLeadingButtonPressed()
        }
    }

    override public func navigationBarTrailingButtonPressed() {
        guard shouldOverrideNavigationEffects else {
            super.navigationBarTrailingButtonPressed()
            return
        }
        switch trailingButtonStyle {
        case .close:
            closeButtonRelay.accept(())
        default:
            super.navigationBarLeadingButtonPressed()
        }
    }

    // MARK: - Private Methods

    private func linkedBankCell(
        for indexPath: IndexPath,
        presenter: LinkedBankAccountCellPresenter
    ) -> UITableViewCell {
        let cell = tableView.dequeue(LinkedBankAccountTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func balanceCell(
        for indexPath: IndexPath,
        presenter: CurrentBalanceCellPresenting
    ) -> UITableViewCell {
        let cell = tableView.dequeue(CurrentBalanceTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func totalBalanceCell(
        for indexPath: IndexPath,
        presenter: AccountGroupBalanceCellPresenter
    ) -> AccountGroupBalanceTableViewCell {
        let cell = tableView.dequeue(AccountGroupBalanceTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func buttonTableViewCell(
        for indexPath: IndexPath,
        viewModel: ButtonViewModel
    ) -> UITableViewCell {
        let cell = tableView.dequeue(
            ButtonsTableViewCell.self,
            for: indexPath
        )
        cell.models = [viewModel]
        return cell
    }
}

extension AccountPickerViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerBuilderForTableView(section: section)?
            .view(
                fittingWidth: view.bounds.width,
                customHeight: nil
            )
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        headerBuilderForTableView(section: section)?.defaultHeight ?? 0
    }

    /// - returns: A `AccountPickerHeaderBuilder` for the given UITableView section, or nil it it should be displayed or doesn't exist.
    private func headerBuilderForTableView(section: Int) -> AccountPickerHeaderBuilder? {
        guard let headerBuilder = headerRelay.value else {
            return nil
        }
        return shouldDisplayHeaderOnTableView(
            section: section,
            headerBuilder: headerBuilder
        ) ? headerBuilder : nil
    }

    /// - returns: `true` if header should be displayed as part of the UITableView, false if not.
    private func shouldDisplayHeaderOnTableView(section: Int, headerBuilder: AccountPickerHeaderBuilder) -> Bool {
        section == 0
            && !headerBuilder.isAlwaysVisible
    }
}
