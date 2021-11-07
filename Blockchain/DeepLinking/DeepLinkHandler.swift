// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureKYCDomain
import FeatureOpenBankingDomain
import FeatureSettingsDomain
import FirebaseAnalytics
import PlatformKit
import PlatformUIKit
import ToolKit

final class DeepLinkHandler: DeepLinkHandling {

    private let appSettings: BlockchainSettings.App
    private let kycSettings: KYCSettingsAPI
    private let openBanking: OpenBanking

    init(
        appSettings: BlockchainSettings.App = resolve(),
        kycSettings: KYCSettingsAPI = resolve()
    ) {
        self.appSettings = appSettings
        self.kycSettings = kycSettings
    }

    func handle(
        deepLink: String,
        supportedRoutes: [DeepLinkRoute] = DeepLinkRoute.allCases
    ) {
        Logger.shared.debug("[DeepLinkHandler] Attempting to handle deep link.")
        guard let route = DeepLinkRoute.route(from: deepLink, supportedRoutes: supportedRoutes),
              let payload = DeepLinkPayload.create(from: deepLink, supportedRoutes: supportedRoutes)
        else {
            Logger.shared.debug("Unhandled deep link \(deepLink)")
            return
        }
        Logger.shared.debug("[DeepLinkHandler] Handling deep link \(deepLink) on route \(route)")
        switch route {
        case .xlmAirdop:
            handleXlmAirdrop(payload.params)
        case .kyc,
             .kycVerifyEmail:
            handleKyc()
        case .kycDocumentResubmission:
            handleKycDocumentResubmission(payload.params)
        case .exchangeVerifyEmail,
             .exchangeLinking:
            handleExchangeLinking(payload.params)
        }
    }

    private func handleXlmAirdrop(_ params: [String: String]) {
        appSettings.didTapOnAirdropDeepLink = true
        appSettings.didAttemptToRouteForAirdrop = false
        Analytics.setUserProperty(FirebaseAnalyticsServiceProvider.Campaigns.sunriver.rawValue, forName: "campaign")
    }

    private func handleKycDocumentResubmission(_ params: [String: String]) {
        kycSettings.didTapOnDocumentResubmissionDeepLink = true
        kycSettings.documentResubmissionLinkReason = params[DeepLinkConstant.documentResubmissionReason]
    }

    private func handleExchangeLinking(_ params: [String: String]) {
        appSettings.didTapOnExchangeDeepLink = true
        appSettings.exchangeLinkIdentifier = params[DeepLinkConstant.linkId]
    }

    private func handleKyc() {
        kycSettings.didTapOnKycDeepLink = true
    }

    /// # Examples
    ///
    /// success: ?one-time-token=...#/open/ob-bank-link
    ///          ?callbackUrl=nabu-gateway/payments/banktransfer/one-time-token
    ///
    /// failure: ?callbackUrl=nabu-gateway%2Fpayments%2Fbanktransfer%2Fone-time-token
    ///          &application-user-id=beneficiary%3A95e826e7-fb58-4020-8815-c4c2839fe8bc
    ///          &user-uuid=c69af99b-291b-4bd9-85af-099a1b948442
    ///          &institution=monzo_ob
    ///          &error=uncategorized_error
    ///          &error-source=institution
    ///          &error-description=VGhpcyByZXF1ZXN0IGhhcyBhbHJlYWR5IGJlZW4gYXV0aG9yaXNlZA%3D%3D
    private func handleOpenBanking(_ params: [String: String]) {
        openBanking.state.transaction { state in
            if let token = params["one-time-token"] {
                state.set(.consent.token, to: token)
            }
            if let error = params["error"] {
                state.set(.consent.error, to: OpenBanking.Error.code(error))
            }
        }
    }
}
