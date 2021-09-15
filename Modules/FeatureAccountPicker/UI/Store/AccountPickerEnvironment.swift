// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineSchedulers
import Foundation
import SwiftUI

public class AccountPickerEnvironment {

    let mainQueue: AnySchedulerOf<DispatchQueue>

    // Effects / Output
    let rowSelected: (AccountPickerRow.ID) -> Void
    let backButtonTapped: () -> Void
    let closeButtonTapped: () -> Void

    // State / Input
    let sections: () -> AnyPublisher<[AccountPickerRow], Never>
    let updateSingleAccount: (AccountPickerRow.SingleAccount) -> AnyPublisher<AccountPickerRow.SingleAccount, Error>?
    let updateAccountGroup: (AccountPickerRow.AccountGroup) -> AnyPublisher<AccountPickerRow.AccountGroup, Error>?

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        rowSelected: @escaping (AccountPickerRow.ID) -> Void,
        backButtonTapped: @escaping () -> Void,
        closeButtonTapped: @escaping () -> Void,
        sections: @escaping () -> AnyPublisher<[AccountPickerRow], Never>,
        // swiftlint:disable line_length
        updateSingleAccount: @escaping (AccountPickerRow.SingleAccount) -> AnyPublisher<AccountPickerRow.SingleAccount, Error>?,
        updateAccountGroup: @escaping (AccountPickerRow.AccountGroup) -> AnyPublisher<AccountPickerRow.AccountGroup, Error>?
        // swiftlint:enable line_length
    ) {
        self.mainQueue = mainQueue
        self.rowSelected = rowSelected
        self.backButtonTapped = backButtonTapped
        self.closeButtonTapped = closeButtonTapped
        self.sections = sections
        self.updateSingleAccount = updateSingleAccount
        self.updateAccountGroup = updateAccountGroup
    }
}
