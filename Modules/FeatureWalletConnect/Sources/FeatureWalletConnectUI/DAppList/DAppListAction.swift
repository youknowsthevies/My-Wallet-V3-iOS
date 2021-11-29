// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureWalletConnectDomain
import Foundation

public enum DAppListAction: Equatable {
    case onAppear
    case loadSessions
    case showSessionDetails(WalletConnectSession)
    case close
    case didReceiveSessions(Result<[WalletConnectSession], Never>)
}
