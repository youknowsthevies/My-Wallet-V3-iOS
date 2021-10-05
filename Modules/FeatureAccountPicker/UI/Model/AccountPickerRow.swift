// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import SwiftUI

public enum AccountPickerRow: Equatable, Identifiable {

    case label(Label)
    case button(Button)
    case linkedBankAccount(LinkedBankAccount)
    case accountGroup(AccountGroup)
    case singleAccount(SingleAccount)

    public var id: AnyHashable {
        switch self {
        case .label(let model):
            return model.id
        case .button(let model):
            return model.id
        case .linkedBankAccount(let model):
            return model.id
        case .accountGroup(let model):
            return model.id
        case .singleAccount(let model):
            return model.id
        }
    }
}
