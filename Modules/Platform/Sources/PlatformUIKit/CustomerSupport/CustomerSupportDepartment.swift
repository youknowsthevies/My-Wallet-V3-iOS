// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum CustomerSupportDepartment: String, Identifiable, CaseIterable {
    public var id: String {
        rawValue
    }

    case identityVerification = "IDENTITY_VERIFICATION"
    case wallet = "WALLET"
    case securityConcern = "SECURITY_CONCERN"
}
