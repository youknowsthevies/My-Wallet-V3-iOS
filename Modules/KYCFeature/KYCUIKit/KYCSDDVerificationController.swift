// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import KYCKit
import Localization
import PlatformKit
import SwiftUI
import UIComponentsKit
import UIKit

final class KYCSDDVerificationController: KYCBaseViewController {

    var kycTiersService: KYCTiersServiceAPI = resolve()
    private var cancellabes = Set<AnyCancellable>()

    override class func make(with coordinator: KYCCoordinator) -> KYCSDDVerificationController {
        let controller = KYCSDDVerificationController()
        controller.coordinator = coordinator
        controller.pageType = .sddVerificationCheck
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        embed(KYCSDDVerificationLoadingView())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        performVerificationCheck()
        hideNavigationBarItems() // required as super resets the navigation bar items
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideNavigationBarItems() // required as super resets the navigation bar items
    }

    // MARK: - UI Configuration

    private func hideNavigationBarItems() {
        // the user should not be able to leave this screen
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItem = nil
        isModalInPresentation = true
    }

    // MARK: - SDD Verification

    private func performVerificationCheck() {
        checkForSDDVerification { [coordinator, pageType] isVerified in
            coordinator?.handle(event: .nextPageFromPageType(pageType, .sddVerification(isVerified: isVerified)))
        }
    }

    private func checkForSDDVerification(completion: @escaping (Bool) -> Void) {
        kycTiersService.checkSimplifiedDueDiligenceVerification()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: completion)
            .store(in: &cancellabes)
    }
}

struct KYCSDDVerificationLoadingView: View {

    var body: some View {
        VStack(spacing: LayoutConstants.VerticalSpacing.betweenContentGroups) {
            ActivityIndicatorView()
            Text(LocalizationConstants.KYC.verificationInProgress)
                .textStyle(.body)
        }
        .background(Color.viewPrimaryBackground)
    }
}
