// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import OnboardingUIKit
import PlatformKit
import PlatformUIKit
import SwiftUI
import UIKit

final class DemoBuyAdapter: OnboardingUIKit.BuyCryptoRouterAPI {

    func presentBuyFlow(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        Deferred {
            Future<OnboardingResult, Never> { completion in
                let view = VStack {
                    Spacer()
                    VStack(spacing: 0) {
                        Text("Buy Flow")
                            .textStyle(.title)
                    }
                    Spacer()
                    PrimaryButton(title: "Continue") {
                        completion(.success(.completed))
                    }
                }
                .padding()
                let hostingViewController = UIHostingController(rootView: view)
                hostingViewController.isModalInPresentation = true
                presenter.show(hostingViewController, sender: self)
            }
        }
        .eraseToAnyPublisher()
    }
}
