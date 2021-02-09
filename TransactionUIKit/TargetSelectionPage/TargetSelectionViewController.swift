//
//  TargetSelectionViewController.swift
//  TransactionUIKit
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
    func connect(state: Driver<TargetSelectionPagePresenter.State>) -> Driver<TargetSelectionPageInteractor.Effects>
}

final class TargetSelectionViewController: BaseScreenViewController, TargetSelectionPageViewControllable {

    // MARK: - Types

    private typealias RxDataSource = RxTableViewSectionedReloadDataSource<TargetSelectionPageSectionModel>

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()
    private let shouldOverrideNavigationEffects: Bool
    private let actionButton = ButtonView()
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
            case .emptyDestination(let viewModel):
                cell = self.selectionCell(for: indexPath, viewModel: viewModel)
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

    func connect(state: Driver<TargetSelectionPagePresenter.State>) -> Driver<TargetSelectionPageInteractor.Effects> {
        disposeBag = DisposeBag()
        tableView.delegate = self

        let stateWait: Driver<TargetSelectionPagePresenter.State> =
            self.rx.viewDidLoad
            .asDriver()
            .flatMap { _ in
                state
            }

        stateWait
            .map(\.navigationModel)
            .drive(weak: self) { (self, model) in
                self.titleViewStyle = model.titleViewStyle
                self.set(barStyle: model.barStyle,
                         leadingButtonStyle: model.leadingButton,
                         trailingButtonStyle: model.trailingButton)
            }
            .disposed(by: disposeBag)

        stateWait.map(\.sections)
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        stateWait.map(\.actionButtonModel)
            .drive(actionButton.rx.viewModel)
            .disposed(by: disposeBag)

        let backButtonEffect = backButtonRelay
            .map { TargetSelectionPageInteractor.Effects.back }
            .asDriverCatchError()

        let closeButtonEffect = closeButtonRelay
            .map { TargetSelectionPageInteractor.Effects.closed }
            .asDriverCatchError()

        return .merge(backButtonEffect, closeButtonEffect)
    }
    // MARK: - Private Methods

    private func setupUI() {
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.separatorColor = .clear
        tableView.alwaysBounceVertical = true
        tableView.register(CurrentBalanceTableViewCell.self)
        tableView.register(SelectionButtonTableViewCell.self)

        view.addSubview(tableView)
        tableView.layoutToSuperview(.top, .leading, .trailing)

        view.addSubview(actionButton)
        actionButton.layoutToSuperview(.centerX)
        actionButton.layout(edge: .top, to: .bottom, of: tableView, relation: .equal)
        actionButton.layoutToSuperview(.leading, usesSafeAreaLayoutGuide: true, offset: Spacing.outer)
        actionButton.layoutToSuperview(.trailing, usesSafeAreaLayoutGuide: true, offset: -Spacing.outer)
        actionButton.layoutToSuperview(.bottom, usesSafeAreaLayoutGuide: true, offset: -Spacing.outer)
        actionButton.layout(dimension: .height, to: 48)
    }

    private func balanceCell(for indexPath: IndexPath, presenter: CurrentBalanceCellPresenting) -> UITableViewCell {
        let cell = tableView.dequeue(CurrentBalanceTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func selectionCell(for indexPath: IndexPath, viewModel: SelectionButtonViewModel) -> UITableViewCell {
        let cell = tableView.dequeue(SelectionButtonTableViewCell.self, for: indexPath)
        cell.viewModel = viewModel
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
