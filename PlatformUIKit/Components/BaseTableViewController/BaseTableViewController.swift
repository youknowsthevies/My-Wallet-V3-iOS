//
//  BaseTableViewController.swift
//  Blockchain
//
//  Created by Daniel Huri on 30/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

open class BaseTableViewController: BaseScreenViewController {

    // MARK: - Public UI Elements
    
    @IBOutlet public var buttonStackView: UIStackView!
    @IBOutlet public var tableView: SelfSizingTableView!
    @IBOutlet public var continueButtonView: ButtonView!
    
    // MARK: - Public UI Constraints
    
    @IBOutlet public var footerHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Setup
    
    public init() {
        super.init(nibName: BaseTableViewController.objectName, bundle: BaseTableViewController.bundle)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
