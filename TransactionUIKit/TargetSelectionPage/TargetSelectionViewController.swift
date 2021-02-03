//
//  PairPageViewController.swift
//  PlatformUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 01/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RIBs
import RxCocoa
import RxDataSources
import RxSwift
import ToolKit
import UIKit

protocol TargetSelectionPageViewControllable: ViewControllable {
    // TODO: Adds correct input/output state
    func connect(state: Driver<Void>) -> Driver<Void>
}

final class TargetSelectionViewController: BaseScreenViewController, TargetSelectionPagePresentable, TargetSelectionPageViewControllable {

    // MARK: - Types

    private typealias RxDataSource = RxTableViewSectionedReloadDataSource<TargetSelectionPageSectionModel>

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()
    private let shouldOverrideNavigationEffects: Bool
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let headerRelay = BehaviorRelay<HeaderBuilder?>(value: nil)
    private let backButtonRelay = PublishRelay<Void>()
    private let closeButtonRelay = PublishRelay<Void>()

    private lazy var dataSource: RxDataSource = {
        RxDataSource(configureCell: { [weak self] dataSource, tableView, indexPath, item in
            guard let self = self else { return UITableViewCell() }
            let cell: UITableViewCell
            switch item.presenter {
            case .singleAccount(let presenter):
                cell = self.balanceCell(for: indexPath, presenter: presenter)
            }
            cell.selectionStyle = .none
            return cell
        })
    }()

    init(shouldOverrideNavigationEffects: Bool) {
        self.shouldOverrideNavigationEffects = shouldOverrideNavigationEffects
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { unimplemented() }

    // MARK: - Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func navigationBarLeadingButtonPressed() {
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

    override func navigationBarTrailingButtonPressed() {
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

    func connect(state: Driver<Void>) -> Driver<Void> {
        return .empty()
    }

    // MARK: - Private Methods

    private func setupUI() {
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.separatorColor = .clear
        tableView.alwaysBounceVertical = true
        tableView.register(CurrentBalanceTableViewCell.self)

        view.addSubview(tableView)
        tableView.layoutToSuperview(.top, .bottom, .leading, .trailing)
    }

    private func balanceCell(for indexPath: IndexPath, presenter: CurrentBalanceCellPresenting) -> UITableViewCell {
        let cell = tableView.dequeue(CurrentBalanceTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }
}

extension TargetSelectionViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        dataSource[section].header.view(fittingWidth: view.bounds.width, customHeight: nil)
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        dataSource[section].header.defaultHeight
    }
}
