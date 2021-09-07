// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

enum CustomerSupportDepartment: String, Identifiable, CaseIterable {
    var id: String {
        rawValue
    }

    case identityVerification = "IDENTITY_VERIFICATION"
    case wallet = "WALLET"
    case securityConcern = "SECURITY_CONCERN"
}

extension CustomerSupportDepartment {

    private typealias LocalizationIds = LocalizationConstants.CustomerSupport.Item

    var title: String {
        switch self {
        case .identityVerification:
            return LocalizationIds.idVerification
        case .wallet:
            return LocalizationIds.wallet
        case .securityConcern:
            return LocalizationIds.securityConcern
        }
    }
}
