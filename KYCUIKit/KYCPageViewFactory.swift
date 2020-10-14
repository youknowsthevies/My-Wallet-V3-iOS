//
//  KYCPageViewFactory.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import KYCKit
import PlatformKit
import ToolKit

/// Factory for constructing a KYCBaseViewController
class KYCPageViewFactory {
    let analyticsService: AnalyticsServiceAPI

    init(analyticsService: AnalyticsServiceAPI = resolve()) {
        self.analyticsService = analyticsService
    }

    // swiftlint:disable:next cyclomatic_complexity
    func createFrom(
        pageType: KYCPageType,
        in coordinator: KYCCoordinator,
        payload: KYCPagePayload? = nil
    ) -> KYCBaseViewController {
        switch pageType {
        case .enterEmail:
            analyticsService.trackEvent(title: "kyc_enter_email")
            return KYCEnterEmailController.make(with: coordinator)
        case .confirmEmail:
            analyticsService.trackEvent(title: "kyc_confirm_email")
            let confirmEmailController = KYCConfirmEmailController.make(with: coordinator)
            if let payload = payload, case let .emailPendingVerification(email) = payload {
                confirmEmailController.email = email
            }
            return confirmEmailController
        case .tier1ForcedTier2:
            analyticsService.trackEvent(title: "kyc_more_info_needed")
            return KYCMoreInformationController.make(with: coordinator)
        case .welcome:
            analyticsService.trackEvent(title: "kyc_welcome")
            analyticsService.trackEvent(title: "kyc_sunriver_start")
            return KYCWelcomeController.make(with: coordinator)
        case .country:
            analyticsService.trackEvent(title: "kyc_country")
            return KYCCountrySelectionController.make(with: coordinator)
        case .states:
            analyticsService.trackEvent(title: "kyc_states")
            let stateController = KYCStateSelectionController.make(with: coordinator)
            if let payload = payload, case let .countrySelected(country) = payload {
                stateController.country = country
            }
            return stateController
        case .profile:
            analyticsService.trackEvent(title: "kyc_profile")
            return KYCPersonalDetailsController.make(with: coordinator)
        case .address:
            analyticsService.trackEvent(title: "kyc_address")
            return KYCAddressController.make(with: coordinator)
        case .enterPhone:
            analyticsService.trackEvent(title: "kyc_enter_phone")
            return KYCEnterPhoneNumberController.make(with: coordinator)
        case .confirmPhone:
            analyticsService.trackEvent(title: "kyc_confirm_phone")
            let confirmPhoneNumberController = KYCConfirmPhoneNumberController.make(with: coordinator)
            if let payload = payload, case let .phoneNumberUpdated(number) = payload {
                confirmPhoneNumberController.phoneNumber = number
            }
            return confirmPhoneNumberController
        case .verifyIdentity:
            analyticsService.trackEvent(title: "kyc_verify_identity")
            return KYCVerifyIdentityController.make(with: coordinator)
        case .resubmitIdentity:
            analyticsService.trackEvent(title: "kyc_resubmit_documents")
            return KYCResubmitIdentityController.make(with: coordinator)
        case .accountStatus:
            analyticsService.trackEvent(title: "kyc_account_status")
            let controller = KYCInformationController.make(with: coordinator)
            if let payload = payload, case let .accountStatus(status: status, isReceivingAirdrop: airdrop) = payload {
                let model = KYCInformationViewModel.create(for: status)
                let config = KYCInformationViewConfig.create(for: status, isReceivingAirdrop: airdrop)
                controller.viewConfig = config
                controller.viewModel = model
            }
            return controller
        case .applicationComplete:
            return KYCApplicationCompleteController.make(with: coordinator)
        }
    }
}
