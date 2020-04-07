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
    
    @IBOutlet private var tableView: UITableView!

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
        setupSearchController()
        setupTableView()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        titleViewStyle = .text(value: presenter.title)
        
        var leading: Screen.Style.LeadingButton = .close
        if let navController = navigationController {
            leading = navController.viewControllers.count > 1 ? .back : .close
        }
        set(barStyle: .darkContent(ignoresStatusBar: false, background: .white),
            leadingButtonStyle: leading,
            trailingButtonStyle: .none)
    }
    
    private func setupSearchController() {
        let searchController = SearchController(placeholderText: presenter.searchBarPlaceholder)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        searchController.text
            .bind(to: presenter.searchTextRelay)
            .disposed(by: disposeBag)
    }
    
    private func setupTableView() {
        
        // Table view setup
        
        if let viewModel = presenter.tableHeaderViewModel {
            let width = tableView.bounds.width
            let height = SelectionScreenTableHeaderView.estimatedHeight(for: width, model: viewModel)
            let headerView = SelectionScreenTableHeaderView(frame: .init(
                origin: .zero,
                size: .init(
                    width: width,
                    height: height
                ))
            )
            headerView.viewModel = viewModel
            tableView.tableHeaderView = headerView
        }
        
        tableView.register(SelectionItemTableViewCell.self)
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 72
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 80, bottom: 0, right: 0)
        
        // Table view binding
        
        presenter.displayPresenters
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

        presenter.preselection
            .take(1)
            .bind(weak: tableView) { (tableView, index) in
                tableView.scrollToRow(
                    at: IndexPath(row: index, section: 0),
                    at: .middle,
                    animated: true
                )
            }
            .disposed(by: disposeBag)
        
        presenter.selection
            .bind(weak: self) { (self) in
                self.presenter.recordSelection()
                if let navController = self.navigationController {
                    navController.popViewController(animated: true)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            .disposed(by: disposeBag)
    }
    
    override public func navigationBarLeadingButtonPressed() {
        super.navigationBarLeadingButtonPressed()
        presenter.navigationBarLeadingButtonTapped()
    }
}
