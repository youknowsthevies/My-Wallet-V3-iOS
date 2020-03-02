//
//  SelectionScreenViewController.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 30/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import PlatformKit

public final class SelectionScreenViewController: BaseScreenViewController {

    // MARK: - IBOutlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Injected
    
    private let presenter: SelectionScreenPresenter
    
    // MARK: - Accessors
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    public init(presenter: SelectionScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: SelectionScreenViewController.objectName, bundle: Bundle(for: Self.self))
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        presenter.viewDidLoad()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        titleViewStyle = .text(value: presenter.title)
        set(barStyle: .lightContent(ignoresStatusBar: false, background: .navigationBarBackground),
            leadingButtonStyle: .close, trailingButtonStyle: .none)
    }
    
    private func setupTableView() {
        
        // Table view setup
        
        tableView.register(SelectionItemTableViewCell.self)
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 72
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 80, bottom: 0, right: 0)
        
        // Table view binding
        
        presenter.presenters
            .bind(
                to: tableView.rx.items(
                    cellIdentifier: SelectionItemTableViewCell.objectName,
                    cellType: SelectionItemTableViewCell.self
                ),
                curriedArgument: { _, presenter, cell in
                    cell.presenter = presenter
                }
            )
            .disposed(by: disposeBag)

        tableView.rx.itemDeselected
            .map { $0.row }
            .bind(to: presenter.deselectionRelay)
            .disposed(by: disposeBag)

        tableView.rx.itemSelected
            .map { $0.row }
            .bind(to: presenter.selectionRelay)
            .disposed(by: disposeBag)

        presenter.selectionRelay
            .take(1)
            .bind(weak: tableView) { (tableView, index) in
                tableView?.selectRow(
                    at: IndexPath(row: index, section: 0),
                    animated: true, scrollPosition: .top
                )
            }
            .disposed(by: disposeBag)
    }
    
    override public func navigationBarLeadingButtonPressed() {
        super.navigationBarLeadingButtonPressed()
        presenter.navigationBarLeadingButtonTapped()
    }
}
