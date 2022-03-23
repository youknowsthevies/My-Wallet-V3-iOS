// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import FeatureOpenBankingDomain

extension AnalyticsEvents.New {

    enum OpenBanking: AnalyticsEvent, Equatable {

        enum Origin: String {
            case settings = "SETTINGS"
        }

        case bankAccountStateTriggered(
            account: FeatureOpenBankingDomain.OpenBanking.BankAccount,
            institution: String? = nil
        )

        case linkBankConditionsApproved(
            account: FeatureOpenBankingDomain.OpenBanking.BankAccount,
            institution: String,
            origin: OpenBanking.Origin
        )

        case linkBankSelected(
            institution: String,
            account: FeatureOpenBankingDomain.OpenBanking.BankAccount
        )

        var type: AnalyticsEventType { .nabu }

        var params: [String: Any]? {
            switch self {
            case .bankAccountStateTriggered(let account, let institution):
                return [
                    "bank_name": (account.details?.bankName ?? institution ?? "").uppercased(),
                    "currency": account.currency ?? "",
                    "entity": account.attributes.entity,
                    "institution_name": institution ?? "",
                    "partner": account.partner,
                    "service": "OPEN_BANKING",
                    "state": account.state?.value ?? "",
                    "type": "BANK_TRANSFER"
                ]
            case .linkBankConditionsApproved(let account, let institution, let origin):
                return [
                    "origin": origin.rawValue,
                    "bank_name": institution,
                    "partner": account.partner,
                    "provider": {
                        switch account.attributes.entity.lowercased() {
                        case "fintecture":
                            return "FINTECTURE"
                        case "safeconnect(uk)", _:
                            return "SAFE_CONNECT"
                        }
                    }()
                ]
            case .linkBankSelected(let institution, let account):
                return [
                    "bank_name": institution,
                    "partner": account.partner
                ]
            }
        }
    }
}

extension AnalyticsEventRecorderAPI {

    func record(event: AnalyticsEvents.New.OpenBanking) {
        record(event: event)
    }
}
