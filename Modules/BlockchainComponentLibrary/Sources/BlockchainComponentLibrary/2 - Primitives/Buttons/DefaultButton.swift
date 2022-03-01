// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// A button that can be customized
public struct DefaultButton<LeadingView: View>: View {

    private let title: String
    private let isLoading: Bool
    private let leadingView: LeadingView
    private let action: () -> Void

    @Environment(\.colorCombination) private var colorCombination
    @Environment(\.pillButtonSize) private var size
    @Environment(\.isEnabled) private var isEnabled

    public init(
        title: String,
        isLoading: Bool = false,
        @ViewBuilder leadingView: () -> LeadingView,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.leadingView = leadingView()
        self.action = action
    }

    public var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: Spacing.padding2) {
                leadingView
                    .frame(width: 24, height: 24)

                Text(title)
            }
        }
        .buttonStyle(
            PillButtonStyle(
                isLoading: isLoading,
                isEnabled: isEnabled,
                size: size,
                colorCombination: colorCombination
            )
        )
    }
}

extension DefaultButton where LeadingView == EmptyView {

    /// Create a primary button without a leading view.
    /// - Parameters:
    ///   - title: Centered title label
    ///   - isLoading: True to display a loading indicator instead of the label.
    ///   - action: Action to be triggered on tap
    public init(
        title: String,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.init(
            title: title,
            isLoading: isLoading,
            leadingView: { EmptyView() },
            action: action
        )
    }
}
