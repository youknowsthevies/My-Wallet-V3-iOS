// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

/// Welcome screen update type
enum LaunchAnnouncementType {

    /// Backend under maintenance
    case maintenance(WalletOptions)

    /// Version update
    case updateIfNeeded(WalletOptions.UpdateType)

    /// Warning about jailbroken phones
    case jailbrokenWarning
}
