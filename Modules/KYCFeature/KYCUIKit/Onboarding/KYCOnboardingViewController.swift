//
//  KYCOnboardingViewController.swift
//  Blockchain
//
//  Created by AlexM on 2/22/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import UIKit

/// NOTE: This is likely temporary. Swap has been moved to the tab bar.
/// Because of this we need a screen that serves as a placeholder and CTA
/// for user's who have not KYC'd. 
public final class KYCOnboardingViewController: UIViewController {

    public var action: (() -> Void)?

    @IBOutlet private var welcomeDescription: UILabel!
    @IBOutlet private var beginNowButton: PrimaryButton!

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizationConstants.KYC.welcome
        welcomeDescription.text = LocalizationConstants.KYC.welcomeMainText
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        beginNowButton.isEnabled = action != nil
    }

    @IBAction func beginNowTapped(_ sender: UIButton) {
        action?()
    }
}
