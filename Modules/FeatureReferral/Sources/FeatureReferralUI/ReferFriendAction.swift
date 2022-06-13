// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

public enum ReferFriendAction: Equatable, BindableAction {
    case binding(BindingAction<ReferFriendState>)
    case onAppear
    case onCopyTapped
    case onShareTapped
    case onShowRefferalTapped
    case onCopyReturn
}
