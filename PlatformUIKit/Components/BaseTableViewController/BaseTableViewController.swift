//
//  BaseTableViewController.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 30/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

open class BaseTableViewController: BaseScreenViewController {

    // MARK: - Public UI Elements
    
    @IBOutlet private var buttonStackView: UIStackView!
    @IBOutlet public var tableView: SelfSizingTableView!
    
    // MARK: - Public UI Constraints
    
    @IBOutlet public var footerHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Setup
    
    public init() {
        super.init(nibName: BaseTableViewController.objectName, bundle: BaseTableViewController.bundle)
    }

    public func addButton(with viewModel: ButtonViewModel) {
        let buttonView = ButtonView()
        buttonView.viewModel = viewModel
        buttonStackView.addArrangedSubview(buttonView)
        buttonView.layout(dimension: .height, to: 48)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
