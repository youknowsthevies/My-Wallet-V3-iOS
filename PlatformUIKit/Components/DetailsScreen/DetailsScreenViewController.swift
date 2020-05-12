//
//  DetailsScreenViewController.swift
//  PlatformUIKit
//
//  Created by Paulo on 29/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

public final class DetailsScreenViewController: BaseTableViewController {

    // MARK: - Injected

    private let presenter: DetailsScreenPresenterAPI

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(presenter: DetailsScreenPresenterAPI) {
        self.presenter = presenter
        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.selfSizingBehaviour = .fill
        presenter.viewDidLoad()
        setupTableView()
        setupNavigationBar()
        for viewModel in presenter.buttons {
            addButton(with: viewModel)
        }
    }

    // MARK: - Setup

    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.register(NoticeTableViewCell.self)
        tableView.register(InteractableTextTableViewCell.self)
        tableView.registerNibCell(LineItemTableViewCell.self)
        tableView.registerNibCell(LabelTableViewCell.self)
        tableView.registerNibCell(SeparatorTableViewCell.self)
        tableView.registerNibCell(ButtonsTableViewCell.self)
        tableView.registerNibCell(BadgeCollectionTableViewCell.self)
    }

    private func setupNavigationBar() {
        switch presenter.navigationBarAppearance {
        case let .custom(leading: leading, trailing: trailing, barStyle: barStyle):
            set(barStyle: barStyle,
                leadingButtonStyle: leading,
                trailingButtonStyle: trailing)
        case .defaultDark:
            setStandardDarkContentStyle()
        }
        titleViewStyle = presenter.titleView
    }

    // MARK: - Navigation

    public override func navigationBarLeadingButtonPressed() {
        switch presenter.navigationBarLeadingButtonAction {
        case .default:
            super.navigationBarLeadingButtonPressed()
        case .custom(let action):
            action()
        }
    }

    public override func navigationBarTrailingButtonPressed() {
        switch presenter.navigationBarTrailingButtonAction {
        case .default:
            super.navigationBarTrailingButtonPressed()
        case .custom(let action):
            action()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension DetailsScreenViewController: UITableViewDelegate, UITableViewDataSource {

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let idx = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        guard presenter.cells.indices.contains(idx) else {
            return
        }
        switch presenter.cells[indexPath.row] {
        case .badges,
             .buttons,
             .label,
             .staticLabel,
             .interactableTextCell,
             .notice,
             .separator:
            break
        case .lineItem(let presenter):
            presenter.tapRelay.accept(())
        }
    }
    
    public func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
        assert(section == 0)
        return presenter.cells.count
    }

    public func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        assert(presenter.cells.indices.contains(indexPath.row))
        switch presenter.cells[indexPath.row] {
        case .badges(let presenters):
            return badgesCell(for: indexPath, presenters: presenters)
        case .buttons(let models):
            return buttonsCell(for: indexPath, models: models)
        case .label(let presenter):
            return labelCell(for: indexPath, presenter: presenter)
        case .staticLabel(let viewModel):
            return staticLabelCell(for: indexPath, viewModel: viewModel)
        case .interactableTextCell(let viewModel):
            return interactableTextCell(for: indexPath, viewModel: viewModel)
        case .lineItem(let presenter):
            return lineItemCell(for: indexPath, presenter: presenter)
        case .notice(let viewModel):
            return noticeCell(for: indexPath, viewModel: viewModel)
        case .separator:
            return separatorCell(for: indexPath)
        }
    }

    // MARK: - Accessors

    private func interactableTextCell(for indexPath: IndexPath, viewModel: InteractableTextViewModel) -> UITableViewCell {
        let cell = tableView.dequeue(InteractableTextTableViewCell.self, for: indexPath)
        cell.contentInset = UIEdgeInsets(horizontal: 24, vertical: 0)
        cell.viewModel = viewModel
        return cell
    }

    private func separatorCell(for indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeue(SeparatorTableViewCell.self, for: indexPath)
    }

    private func lineItemCell(for indexPath: IndexPath, presenter: LineItemCellPresenting) -> UITableViewCell {
        let cell = tableView.dequeue(LineItemTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func badgesCell(for indexPath: IndexPath, presenters: [BadgeAssetPresenting]) -> UITableViewCell {
        let cell = tableView.dequeue(BadgeCollectionTableViewCell.self, for: indexPath)
        cell.presenters = presenters
        return cell
    }

    private func buttonsCell(for indexPath: IndexPath, models: [ButtonViewModel]) -> UITableViewCell {
        let cell = tableView.dequeue(ButtonsTableViewCell.self, for: indexPath)
        cell.models = models
        return cell
    }

    private func staticLabelCell(for indexPath: IndexPath, viewModel: LabelContent) -> UITableViewCell {
        let cell = tableView.dequeue(LabelTableViewCell.self, for: indexPath)
        cell.content = viewModel
        return cell
    }

    private func labelCell(for indexPath: IndexPath, presenter: LabelContentPresenting) -> UITableViewCell {
        let cell = tableView.dequeue(LabelTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func noticeCell(for indexPath: IndexPath, viewModel: NoticeViewModel) -> UITableViewCell {
        let cell = tableView.dequeue(NoticeTableViewCell.self, for: indexPath)
        cell.viewModel = viewModel
        return cell
    }
}

