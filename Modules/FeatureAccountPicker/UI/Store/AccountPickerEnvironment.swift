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
    let search: (String?) -> Void

    // State / Input
    let sections: () -> AnyPublisher<[AccountPickerRow], Never>

    let updateSingleAccount: (AccountPickerRow.SingleAccount)
        -> AnyPublisher<AccountPickerRow.SingleAccount.Balances, Error>?

    let updateAccountGroup: (AccountPickerRow.AccountGroup)
        -> AnyPublisher<AccountPickerRow.AccountGroup.Balances, Error>?

    let header: () -> AnyPublisher<Header, Error>

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        rowSelected: @escaping (AccountPickerRow.ID) -> Void,
        backButtonTapped: @escaping () -> Void,
        closeButtonTapped: @escaping () -> Void,
        search: @escaping (String?) -> Void,
        sections: @escaping () -> AnyPublisher<[AccountPickerRow], Never>,
        // swiftlint:disable line_length
        updateSingleAccount: @escaping (AccountPickerRow.SingleAccount) -> AnyPublisher<AccountPickerRow.SingleAccount.Balances, Error>?,
        updateAccountGroup: @escaping (AccountPickerRow.AccountGroup) -> AnyPublisher<AccountPickerRow.AccountGroup.Balances, Error>?,
        // swiftlint:enable line_length
        header: @escaping () -> AnyPublisher<Header, Error>
    ) {
        self.mainQueue = mainQueue
        self.rowSelected = rowSelected
        self.backButtonTapped = backButtonTapped
        self.closeButtonTapped = closeButtonTapped
        self.search = search
        self.sections = sections
        self.updateSingleAccount = updateSingleAccount
        self.updateAccountGroup = updateAccountGroup
        self.header = header
    }
}
