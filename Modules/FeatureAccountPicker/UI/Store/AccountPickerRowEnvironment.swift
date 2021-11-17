// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineSchedulers
import Foundation
import SwiftUI

struct AccountPickerRowEnvironment {

    let mainQueue: AnySchedulerOf<DispatchQueue>

    // State / Input

    let updateSingleAccount: (AccountPickerRow.SingleAccount)
        -> AnyPublisher<AccountPickerRow.SingleAccount.Balances, Error>?

    let updateAccountGroup: (AccountPickerRow.AccountGroup)
        -> AnyPublisher<AccountPickerRow.AccountGroup.Balances, Error>?
}
