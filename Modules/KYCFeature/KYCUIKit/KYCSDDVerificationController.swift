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
    private var loadingView = KYCSDDVerificationLoadingView()

    override class func make(with coordinator: KYCCoordinator) -> KYCSDDVerificationController {
        let controller = KYCSDDVerificationController()
        controller.coordinator = coordinator
        controller.pageType = .sddVerificationCheck
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.retryCallback = performVerificationCheck
        embed(loadingView)
        performVerificationCheck()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        loadingView.loading = true
        checkForSDDVerification { [coordinator, pageType, loadingView] isVerified in
            coordinator?.handle(event: .nextPageFromPageType(pageType, .sddVerification(isVerified: isVerified)))
            loadingView.loading = false
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

    @State var loading: Bool = false
    var retryCallback: (() -> Void)?

    var body: some View {
        VStack(spacing: LayoutConstants.VerticalSpacing.betweenContentGroups) {
            if loading {
                ActivityIndicatorView()
                VStack(spacing: 0) {
                    Text(LocalizationConstants.KYC.verificationInProgress)
                        .textStyle(.heading)
                    Text(LocalizationConstants.KYC.verificationInProgressWait)
                        .textStyle(.body)
                }
            } else {
                VStack(spacing: 0) {
                    Text(LocalizationConstants.KYC.verificationCompletedTitle)
                        .textStyle(.heading)
                    Text(LocalizationConstants.KYC.verificationCompletedMessage)
                        .textStyle(.body)
                }
                SecondaryButton(title: LocalizationConstants.KYC.retryAction) {
                    retryCallback?()
                }
            }
        }
        .padding()
        .background(Color.viewPrimaryBackground)
    }
}
