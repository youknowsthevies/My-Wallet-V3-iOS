//
//  BuyIntroScreenViewController.swift
//  Blockchain
//
//  Created by Daniel Huri on 21/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

/// A introductory screen for simple buy flow
final class BuyIntroScreenViewController: BaseScreenViewController {
    
    // MARK: - UI Properties
    
    @IBOutlet private var announcementCardContainerView: UIView!
    @IBOutlet private var themeBackgroundImageView: UIImageView!
    @IBOutlet private var continueButtonView: ButtonView!
    @IBOutlet private var skipButtonView: ButtonView!
    
    // MARK: - Injected
    
    private let presenter: BuyIntroScreenPresenter
    
    // MARK: - Accessors
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    init(presenter: BuyIntroScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: BuyIntroScreenViewController.objectName, bundle: Self.bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        
        let announcementCardView = AnnouncementCardView(using: presenter.cardViewModel)
        announcementCardContainerView.addSubview(announcementCardView)
        announcementCardView.fillSuperview()
        
        themeBackgroundImageView.set(presenter.themeBackgroundImageViewContent)
        
        continueButtonView.viewModel = presenter.continueButtonViewModel
        skipButtonView.viewModel = presenter.skipButtonViewModel
    }
    
    // MARK: - Setup

    private func setupNavigationBar() {
        titleViewStyle = .text(value: presenter.title)
        setStandardDarkContentStyle()
    }

    // MARK: - Navigation
    
    override func navigationBarLeadingButtonPressed() {
        presenter.previous()
    }
    
    override func navigationBarTrailingButtonPressed() {
        presenter.previous()
    }
}
