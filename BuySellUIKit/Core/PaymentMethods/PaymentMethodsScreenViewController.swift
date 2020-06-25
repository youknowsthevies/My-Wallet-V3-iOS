//
//  PaymentMethodsScreenViewController.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxSwift

final class PaymentMethodsScreenViewController: BaseScreenViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private var tableView: UITableView!

    // MARK: - Injected
    
    private let presenter: PaymentMethodsScreenPresenter
    
    // MARK: - Accessors
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    init(presenter: PaymentMethodsScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: PaymentMethodsScreenViewController.objectName, bundle: Self.bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        titleViewStyle = .text(value: presenter.title)
        setStandardDarkContentStyle()
    }
        
    private func setupTableView() {
        tableView.register(SelectionButtonTableViewCell.self)
        tableView.registerNibCell(LinkedCardTableViewCell.self)
        tableView.allowsSelection = false
        tableView.separatorInset = .zero
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        
        presenter.cellViewModelTypes
            .drive(
                onNext: { [weak tableView] _ in
                    tableView?.reloadData()
                }
            )
            .disposed(by: disposeBag)
    }
    
    // MARK: - Navigation
    
    override func navigationBarLeadingButtonPressed() {
        presenter.previous()
    }
    
    override func navigationBarTrailingButtonPressed() {
        presenter.previous()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension PaymentMethodsScreenViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.cellViewModelTypesRelay.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = presenter.cellViewModelTypesRelay.value[indexPath.row]
        switch cellType {
        case .suggestedPaymentMethod(let viewModel):
            return suggestedPaymentMethodCell(for: indexPath, viewModel: viewModel)
        case .linkedCard(let presenter):
            return linkedCardTableViewCell(for: indexPath, presenter: presenter)
        }
    }
    
    private func suggestedPaymentMethodCell(for indexPath: IndexPath,
                                            viewModel: SelectionButtonViewModel) -> UITableViewCell {
        let cell = tableView.dequeue(SelectionButtonTableViewCell.self, for: indexPath)
        cell.viewModel = viewModel
        return cell
    }
    
    private func linkedCardTableViewCell(for indexPath: IndexPath,
                                         presenter: LinkedCardCellPresenter) -> UITableViewCell {
        let cell = tableView.dequeue(LinkedCardTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }
}
