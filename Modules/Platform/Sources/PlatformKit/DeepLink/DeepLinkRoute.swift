// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum DeepLinkRoute: CaseIterable {
    case xlmAirdop
    case kyc
    case kycVerifyEmail
    case kycDocumentResubmission
    case exchangeVerifyEmail
    case exchangeLinking
    case openBankingLink
    case openBankingApprove
}

extension DeepLinkRoute {

    public static func route(
        from url: String,
        supportedRoutes: [DeepLinkRoute] = DeepLinkRoute.allCases
    ) -> DeepLinkRoute? {
        guard let url = URL(string: url) else {
            return nil
        }

        let fragment = url.fragment.flatMap { fragment in
            URL(string: fragment)
        }

        let path: String
        let parameters: [String: String]

        if let fragment = fragment {
            path = fragment.path
            parameters = url.queryArgs.merging(fragment.queryArgs, uniquingKeysWith: { $1 })
        } else {
            path = url.path
            parameters = url.queryArgs
        }

        return DeepLinkRoute.route(
            path: path,
            parameters: parameters,
            supportedRoutes: supportedRoutes
        )
    }

    private static func route(
        path: String,
        parameters: [String: String]?,
        supportedRoutes: [DeepLinkRoute] = DeepLinkRoute.allCases
    ) -> DeepLinkRoute? {
        supportedRoutes.first { route -> Bool in
            if path.hasSuffix(route.supportedPath) {
                if let key = route.requiredKeyParam,
                   let value = route.requiredValueParam,
                   let routeParameters = parameters
                {

                    if let optionalKey = route.optionalKeyParameter,
                       let value = routeParameters[optionalKey],
                       let context = FlowContext(rawValue: value)
                    {
                        return route == .exchangeVerifyEmail && context == .exchangeSignup
                    } else {
                        return routeParameters[key] == value
                    }
                }
                return true
            }
            return false
        }
    }

    private var supportedPath: String {
        switch self {
        case .xlmAirdop:
            return "referral"
        case .kycVerifyEmail,
             .kycDocumentResubmission,
             .exchangeVerifyEmail:
            return "login"
        case .kyc:
            return "kyc"
        case .exchangeLinking:
            return "link-account"
        case .openBankingLink:
            return "ob-bank-link"
        case .openBankingApprove:
            return "ob-bank-approval"
        }
    }

    private var requiredKeyParam: String? {
        switch self {
        case .xlmAirdop:
            return "campaign"
        case .kyc,
             .kycVerifyEmail,
             .kycDocumentResubmission,
             .exchangeVerifyEmail:
            return "deep_link_path"
        case .exchangeLinking:
            return nil
        case .openBankingLink, .openBankingApprove:
            return nil
        }
    }

    private var requiredValueParam: String? {
        switch self {
        case .xlmAirdop:
            return "sunriver"
        case .kycVerifyEmail,
             .exchangeVerifyEmail:
            return "email_verified"
        case .kycDocumentResubmission:
            return "verification"
        case .kyc:
            return "kyc"
        case .exchangeLinking:
            return nil
        case .openBankingLink, .openBankingApprove:
            return nil
        }
    }

    private var optionalKeyParameter: String? {
        switch self {
        case .exchangeVerifyEmail,
             .kycVerifyEmail:
            return "context"
        case .kyc,
             .kycDocumentResubmission,
             .xlmAirdop,
             .exchangeLinking,
             .openBankingLink,
             .openBankingApprove:
            return nil
        }
    }
}
