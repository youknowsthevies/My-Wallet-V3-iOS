// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .top, spacing: 16.0) {
            Image(
                configuration.isOn ? "checkbox-on" : "checkbox-off",
                bundle: .UIComponents
            )
            .resizable()
            .frame(width: 22, height: 22)
            .onTapGesture { configuration.isOn.toggle() }
            Button {
                configuration.isOn.toggle()
            } label: {
                Label {
                    configuration.label
                } icon: {
                    Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(configuration.isOn ? .accentColor : .secondary)
                        .accessibility(label: Text(configuration.isOn ? "Checked" : "Unchecked"))
                        .imageScale(.large)
                }
                // Hide the image for this label as the image is shown to the
                // left of this label and we want to apply our own spacing
                .labelStyle(TitleOnlyLabelStyle())
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

private struct CheckboxDemoView: View {
    @State private var isOn = true

    var body: some View {
        Toggle(
            // swiftlint:disable line_length
            "By accepting this, you agree to transfer $100.00 (0.0021037 BTC) frfom your BTC Trading Account to your BTC Rewards Account. An initial hold period of 7 days will be applied to your funds.",
            isOn: $isOn
        )
        .toggleStyle(CheckboxToggleStyle())
    }
}

#if DEBUG
struct CheckboxToggleStyle_Previews: PreviewProvider {
    static var previews: some View {
        CheckboxDemoView()
    }
}
#endif
