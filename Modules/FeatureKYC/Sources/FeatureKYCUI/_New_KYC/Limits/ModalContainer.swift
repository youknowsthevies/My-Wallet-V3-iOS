// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#if canImport(SharedComponentLibrary)
import SharedComponentLibrary
#else
import ComponentLibrary
#endif
import SwiftUI

struct ModalContainer<Content: View>: View {

    private let title: String
    private let closeAction: () -> Void
    @ViewBuilder private let content: () -> Content

    init(
        title: String,
        onClose: @autoclosure @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        closeAction = onClose
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            HStack(alignment: .top) {
                Text(title)
                    .typography(.title3)
                    // pad top with the close button size
                    .padding([.top], 12)
                Spacer()
                IconButton(icon: .closev2.circle(), action: closeAction)
                    .frame(width: 24, height: 24)
            }
            .padding(Spacing.padding3)

            content()
                .frame(maxWidth: .infinity)

            Spacer()
        }
        .background(Color.semantic.background)
    }
}

struct ModalContainer_Previews: PreviewProvider {
    static var previews: some View {
        ModalContainer(title: "My Modal", onClose: print("Close")) {
            VStack {
                Text("Hello, World!")
            }
        }
    }
}
