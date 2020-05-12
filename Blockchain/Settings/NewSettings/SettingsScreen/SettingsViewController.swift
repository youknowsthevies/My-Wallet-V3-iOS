//
//  SettingsViewController.swift
//  Blockchain
//
//  Created by AlexM on 12/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxSwift
import RxCocoa
import RxDataSources
import ToolKit

final class SettingsViewController: BaseScreenViewController {
    
    // MARK: - Accessibility
    
    private typealias AccessibilityIDs = Accessibility.Identifier.Settings.SettingsCell
    private typealias RxDataSource = RxTableViewSectionedAnimatedDataSource<SettingsSectionViewModel>
    
    // MARK: - Private IBOutlets
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Private Properties
    
    private let presenter: SettingsScreenPresenter
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(presenter: SettingsScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: SettingsViewController.objectName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizationConstants.settings
        setupTableView()
        presenter.refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    // MARK: - Private Functions
    
    private func setupNavigationBar() {
        titleViewStyle = .text(value: LocalizationConstants.settings)
        set(barStyle: presenter.barStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: presenter.trailingButton
        )
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .background
        tableView.tableFooterView = AboutView()
        tableView.tableFooterView?.frame = .init(
            origin: .zero,
            size: .init(width: tableView.bounds.width,
                        height: AboutView.estimatedHeight(for: tableView.bounds.width))
        )
        tableView.estimatedRowHeight = 80
        tableView.estimatedSectionHeaderHeight = 70
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerNibCell(SwitchTableViewCell.self)
        tableView.registerNibCell(ClipboardTableViewCell.self)
        tableView.registerNibCell(BadgeTableViewCell.self)
        tableView.registerNibCell(PlainTableViewCell.self)
        tableView.registerNibCell(AddCardTableViewCell.self)
        tableView.registerNibCell(LinkedCardTableViewCell.self)
        tableView.registerHeaderView(TableHeaderView.objectName)
        
        let dataSource = RxDataSource(configureCell: { [weak self] _, _, indexPath, item in
            guard let self = self else { return UITableViewCell() }
            let cell: UITableViewCell
            switch item.cellType {
            case .badge(_, let presenter):
                cell = self.badgeCell(for: indexPath, presenter: presenter)
            case .clipboard(let type):
                cell = self.clipboardCell(for: indexPath, viewModel: type.viewModel)
            case .plain(let type):
                cell = self.plainCell(for: indexPath, viewModel: type.viewModel)
            case .cards(let type):
                switch type {
                case .addCard(let presenter):
                    cell = self.addCardCell(for: indexPath, presenter: presenter)
                case .linkedCard(let presenter):
                    cell = self.linkedCardCell(for: indexPath, presenter: presenter)
                }
            case .switch(_, let presenter):
                cell = self.switchCell(for: indexPath, presenter: presenter)
            }
            cell.selectionStyle = .none
            return cell
        })
        
        presenter.sectionObservable
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(SettingsCellViewModel.self)
            .bind(weak: self) { (self, model) in
                model.recordSelection()
                self.presenter.actionRelay.accept(model.action)
            }
            .disposed(by: disposeBag)
    }
    
    override func navigationBarLeadingButtonPressed() {
        presenter.navigationBarLeadingButtonTapped()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableHeaderView.objectName) as? TableHeaderView else { return nil }
        let section = presenter.sectionArrangement[section]
        let viewModel = TableHeaderViewModel.settings(title: section.sectionTitle)
        header.viewModel = viewModel
        return header
    }
    
    private func switchCell(for indexPath: IndexPath, presenter: SwitchCellPresenting) -> SwitchTableViewCell {
        let cell = tableView.dequeue(SwitchTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }
    
    private func clipboardCell(for indexPath: IndexPath, viewModel: ClipboardCellViewModel) -> ClipboardTableViewCell {
        let cell = tableView.dequeue(ClipboardTableViewCell.self, for: indexPath)
        cell.viewModel = viewModel
        return cell
    }
    
    private func plainCell(for indexPath: IndexPath, viewModel: PlainCellViewModel) -> PlainTableViewCell {
        let cell = tableView.dequeue(PlainTableViewCell.self, for: indexPath)
        cell.viewModel = viewModel
        return cell
    }
    
    private func addCardCell(for indexPath: IndexPath, presenter: AddCardCellPresenter) -> AddCardTableViewCell {
        let cell = tableView.dequeue(AddCardTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }
    
    private func linkedCardCell(for indexPath: IndexPath,
                                presenter: LinkedCardCellPresenter) -> LinkedCardTableViewCell {
        let cell = tableView.dequeue(LinkedCardTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }
    
    private func badgeCell(for indexPath: IndexPath, presenter: BadgeCellPresenting) -> BadgeTableViewCell {
        let cell = tableView.dequeue(BadgeTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }
}
