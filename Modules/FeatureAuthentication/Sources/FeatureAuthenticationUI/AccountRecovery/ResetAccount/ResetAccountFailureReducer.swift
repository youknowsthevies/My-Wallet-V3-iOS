// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import DIKit
import FeatureAuthenticationDomain
import ToolKit

public enum ResetAccountFailureAction: Equatable {
    public enum URLContent {
        case support
        case learnMore

        var url: URL? {
            switch self {
            case .support:
                return URL(string: Constants.SupportURL.ResetAccount.recoveryFailureSupport)
            case .learnMore:
                return URL(string: Constants.SupportURL.ResetAccount.learnMore)
            }
        }
    }

    case open(urlContent: URLContent)
    case none
}

struct ResetAccountFailureState: Equatable {}

struct ResetAccountFailureEnvironment {
    let externalAppOpener: ExternalAppOpener

    init(
        externalAppOpener: ExternalAppOpener = resolve()
    ) {
        self.externalAppOpener = externalAppOpener
    }
}

let resetAccountFailureReducer = Reducer<
    ResetAccountFailureState,
    ResetAccountFailureAction,
    ResetAccountFailureEnvironment
> { _, action, environment in
    switch action {
    case .open(let urlContent):
        guard let url = urlContent.url else {
            return .none
        }
        environment.externalAppOpener.open(url)
        return .none
    case .none:
        return .none
    }
}
