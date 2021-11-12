// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

struct TabBarButton: View {
    @Binding var isOn: Bool

    let icon: Icon
    let title: String

    init(isOn: Binding<Bool>, icon: Icon, title: String) {
        _isOn = isOn
        self.icon = icon
        self.title = title
    }

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(spacing: 0) {
                Group { // Group with fixed height to center-align icons
                    icon
                        .frame(width: 24)
                }
                .frame(height: 32)

                Spacer(minLength: 0)

                Text(title)
                    .typography(.micro)
                    .padding(.bottom, 2)
            }
        }
        .toggleStyle(TabBarButtonStyle())
    }
}

struct TabBarButtonStyle: ToggleStyle {
    let onColor: Color = .semantic.primary
    let offColor = Color(
        light: .palette.grey400,
        dark: .palette.grey400
    )

    func makeBody(configuration: Configuration) -> some View {
        Button(
            action: { configuration.isOn.toggle() },
            label: {
                configuration.label
                    .foregroundColor(configuration.isOn ? onColor : offColor)
                    .accentColor(configuration.isOn ? onColor : offColor)
            }
        )
        .frame(height: 48)
    }
}

struct TabBarButton_Previews: PreviewProvider {
    static var previews: some View {
        TabBarButton(
            isOn: .constant(false),
            icon: .home,
            title: "Home"
        )
        .previewLayout(.sizeThatFits)

        TabBarButton(
            isOn: .constant(true),
            icon: .home,
            title: "Home"
        )
        .previewLayout(.sizeThatFits)
    }
}
