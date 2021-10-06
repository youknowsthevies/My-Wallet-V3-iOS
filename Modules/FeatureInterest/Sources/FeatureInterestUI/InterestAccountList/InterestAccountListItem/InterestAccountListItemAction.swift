// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

enum InterestAccountListItemAction: Equatable {
    case earnInterestButtonTapped
    case viewInterestButtonTapped(CurrencyType)
}
