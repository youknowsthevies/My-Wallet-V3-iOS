//
//  BuyIntroScreenViewController.swift
//  Blockchain
//
//  Created by Daniel Huri on 21/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import ToolKit
import PlatformUIKit

/// A introductory screen for simple buy flow
final class BuyIntroScreenViewController: BaseScreenViewController {

    // MARK: - Properties
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Injected
    
    private let presenter: BuyIntroScreenPresenter
    
    // MARK: - Accessors
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    init(presenter: BuyIntroScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: BuyIntroScreenViewController.objectName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
    }
    
    // MARK: - Setup

    private func setupNavigationBar() {
        titleViewStyle = .text(value: presenter.title)
        set(barStyle: .lightContent(ignoresStatusBar: false, background: .navigationBarBackground),
            leadingButtonStyle: .back)
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 250
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.register(AnnouncementTableViewCell.self)
    }
    
    // MARK: - Navigation
    
    override func navigationBarLeadingButtonPressed() {
        presenter.navigationBarLeadingButtonTapped()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension BuyIntroScreenViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return presenter.cellCount
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(AnnouncementTableViewCell.self, for: indexPath)
        let row = indexPath.row
        cell.viewModel = presenter.viewModels[row]
        cell.bottomSpacing = row == 0 ? 16 : 0
        return cell
    }
}
