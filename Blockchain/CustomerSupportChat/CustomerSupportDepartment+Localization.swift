// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

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
