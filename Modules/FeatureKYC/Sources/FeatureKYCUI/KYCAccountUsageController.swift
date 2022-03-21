// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureFormDomain
import FeatureKYCDomain
import Localization
import NabuNetworkError
import UIComponentsKit
import UIKit

final class KYCAccountUsageController: KYCBaseViewController {

    override class func make(with coordinator: KYCRouter) -> KYCBaseViewController {
        let controller = KYCAccountUsageController()
        controller.pageType = .accountUsageForm
        controller.router = coordinator
        return controller
    }

    let accountUsageService: KYCAccountUsageServiceAPI = DIKit.resolve()

    override func viewDidLoad() {
        super.viewDidLoad()
        embedAccountUsageView()
        title = LocalizationConstants.NewKYC.Steps.AccountUsage.title
    }

    private func embedAccountUsageView() {
        let view = AccountUsageView(
            store: .init(
                initialState: AccountUsage.State.idle,
                reducer: AccountUsage.reducer,
                environment: AccountUsage.Environment(
                    onComplete: continueToNextStep,
                    loadForm: accountUsageService.fetchAccountUsageForm,
                    submitForm: accountUsageService.submitAccountUsageForm
                )
            )
        )
        embed(view)
    }

    private func continueToNextStep() {
        router.handle(event: .nextPageFromPageType(pageType, nil))
    }

    // MARK: - UI Configuration

    override func navControllerCTAType() -> NavigationCTA {
        .none
    }
}
