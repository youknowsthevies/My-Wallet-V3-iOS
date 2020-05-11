//
//  CardDetailsScreenViewController.swift
//  Blockchain
//
//  Created by Daniel Huri on 17/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformUIKit

final class CardDetailsScreenViewController: BaseTableViewController {

    // MARK: - Injected
    
    private let keyboardObserver = KeyboardObserver()
    private let presenter: CardDetailsScreenPresenter
    private let alertPresenter: AlertViewPresenterAPI
    
    private var keyboardInteractionController: KeyboardInteractionController!
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(presenter: CardDetailsScreenPresenter,
         alertPresenter: AlertViewPresenterAPI = AlertViewPresenter.shared) {
        self.presenter = presenter
        self.alertPresenter = alertPresenter
        super.init()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        addButton(with: presenter.buttonViewModel)
        keyboardInteractionController = KeyboardInteractionController(
            in: self,
            disablesToolBar: true
        )
        setupTableView()
        setupKeyboardObserver()
        
        presenter.error
            .emit(onNext: { [weak self] error in
                guard let self = self else { return }
                switch error {
                case .cardAlreadySaved:
                    typealias LocalizedString = LocalizationConstants.CardDetailsScreen.Alert
                    self.alertPresenter.notify(
                        content: .init(
                            title: LocalizedString.title,
                            message: LocalizedString.message
                        ),
                        in: self
                    )
                case .generic:
                    self.alertPresenter.error(in: self, action: nil)
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keyboardObserver.setup()
        presenter.viewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardObserver.remove()
    }
    
    private func setupNavigationBar() {
        titleViewStyle = .text(value: presenter.title)
        setStandardDarkContentStyle()
    }
    
    private func setupKeyboardObserver() {
        keyboardObserver.state
            .bind(weak: self) { (self, state) in
                switch state.visibility {
                case .visible:
                    self.tableViewBottomConstraint.constant = state.payload.height
                case .hidden:
                    self.tableViewBottomConstraint.constant = 0
                }
                self.view.layoutIfNeeded()
            }
            .disposed(by: disposeBag)
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(TextFieldTableViewCell.self)
        tableView.register(DoubleTextFieldTableViewCell.self)
        tableView.register(NoticeTableViewCell.self)
        tableView.separatorColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Navigation
    
    override func navigationBarTrailingButtonPressed() {
        presenter.previous()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension CardDetailsScreenViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func textFieldCell(for row: Int, type: TextFieldType) -> UITableViewCell {
        let cell = tableView.dequeue(
            TextFieldTableViewCell.self,
            for: IndexPath(row: row, section: 0)
        )
        cell.setup(
            viewModel: presenter.textFieldViewModelByType[type]!,
            keyboardInteractionController: keyboardInteractionController,
            scrollView: tableView
        )
        return cell
    }
    
    private func doubleTextFieldCell(for row: Int,
                                     leadingType: TextFieldType,
                                     trailingType: TextFieldType) -> UITableViewCell {
        let cell = tableView.dequeue(
            DoubleTextFieldTableViewCell.self,
            for: IndexPath(row: row, section: 0)
        )
        cell.setup(
            viewModel: .init(
                leading: presenter.textFieldViewModelByType[leadingType]!,
                trailing: presenter.textFieldViewModelByType[trailingType]!
            ),
            keyboardInteractionController: keyboardInteractionController,
            scrollView: tableView
        )
        return cell
    }
    
    private func privacyNoticeCell(for type: CardDetailsScreenPresenter.CellType) -> UITableViewCell {
        let cell = tableView.dequeue(
            NoticeTableViewCell.self,
            for: IndexPath(row: type.row, section: 0)
        )
        cell.viewModel = presenter.noticeViewModel
        cell.topOffset = 20
        cell.bottomOffset = 48
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = CardDetailsScreenPresenter.CellType(indexPath.row)
        switch cellType {
        case .textField(let type):
            return textFieldCell(for: cellType.row, type: type)
        case .doubleTextField(let leadingType, let trailingType):
            return doubleTextFieldCell(
                for: cellType.row,
                leadingType: leadingType,
                trailingType: trailingType
            )
        case .privacyNotice:
            return privacyNoticeCell(for: cellType)
        }
    }
}
