// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public struct FloatingActionButton: View {
    @Binding var isOn: Bool

    public init(isOn: Binding<Bool>) {
        _isOn = isOn
    }

    public var body: some View {
        Toggle(isOn: $isOn) {
            EmptyView()
        }
        .toggleStyle(FloatingActionToggleStyle())
    }
}

struct FloatingActionToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(
            action: {
                configuration.isOn.toggle()
            },
            label: {
                if configuration.isOn {
                    Image("FAB Selected", bundle: .componentLibrary)
                } else {
                    Image("FAB Default", bundle: .componentLibrary)
                }
            }
        )
    }
}

struct FloatingActionButton_Previews: PreviewProvider {

    static var previews: some View {
        FloatingActionButton(isOn: .constant(false))
            .previewLayout(.sizeThatFits)

        FloatingActionButton(isOn: .constant(true))
            .previewLayout(.sizeThatFits)
    }
}
