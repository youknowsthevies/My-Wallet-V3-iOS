// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import FeatureOpenBankingDomain

extension AnalyticsEvents.New {

    enum OpenBanking: AnalyticsEvent, Equatable {

        case bankAccountStateTriggered(
            account: FeatureOpenBankingDomain.OpenBanking.BankAccount,
            institution: String? = nil
        )

        case linkBankConditionsApproved(
            account: FeatureOpenBankingDomain.OpenBanking.BankAccount,
            institution: String
        )

        case linkBankSelected(
            institution: String
        )

        var type: AnalyticsEventType { .nabu }

        var params: [String: Any]? {
            switch self {
            case .bankAccountStateTriggered(let account, let institution):
                return [
                    "bank_name": String(describing: account.details?.bankName ?? institution).uppercased(),
                    "currency": String(describing: account.currency),
                    "entity": account.attributes.entity,
                    "institution_name": String(describing: institution),
                    "partner": account.partner,
                    "service": "OPEN_BANKING",
                    "state": String(describing: account.state?.value),
                    "type": "BANK_TRANSFER"
                ]
            case .linkBankConditionsApproved(let account, let institution):
                return [
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
            case .linkBankSelected(let institution):
                return [
                    "bank_name": institution
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
