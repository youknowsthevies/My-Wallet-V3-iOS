// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct FailureState<Action> {

    struct Button {

        enum Style {
            case cancel
            case primary
            case destructive
        }

        let title: String
        let style: Style
        let loading: Bool
        let action: Action

        init(title: String, style: Style, loading: Bool = false, action: Action) {
            self.title = title
            self.style = style
            self.loading = loading
            self.action = action
        }
    }

    let title: String
    let message: String?
    let buttons: [Button]
}

extension FailureState.Button: Equatable where Action: Equatable {}
extension FailureState: Equatable where Action: Equatable {}

extension FailureState.Button {

    static func cancel(title: String, loading: Bool = false, action: Action) -> Self {
        .init(title: title, style: .cancel, loading: loading, action: action)
    }

    static func primary(title: String, loading: Bool = false, action: Action) -> Self {
        .init(title: title, style: .primary, loading: loading, action: action)
    }

    static func destructive(title: String, loading: Bool = false, action: Action) -> Self {
        .init(title: title, style: .destructive, loading: loading, action: action)
    }
}
