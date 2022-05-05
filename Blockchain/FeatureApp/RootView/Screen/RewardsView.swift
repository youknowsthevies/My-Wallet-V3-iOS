//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import FeatureInterestUI
import SwiftUI

struct RewardsView: UIViewControllerRepresentable {

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    func makeUIViewController(context: Context) -> some UIViewController {
        InterestAccountListHostingController(embeddedInNavigationView: false)
    }
}
