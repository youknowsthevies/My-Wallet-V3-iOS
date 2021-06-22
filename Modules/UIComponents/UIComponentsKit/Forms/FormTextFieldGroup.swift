import Combine
import SwiftUI

public struct FormTextFieldGroup: View {

    public var title: String
    public let text: Binding<String>
    public let textPlaceholder: String
    public let footnote: Binding<String>?
    public let isDisabled: Bool
    public let isSecure: Bool
    public let error: ((_ text: String) -> Bool)?
    public let errorMessage: String?
    @State private var isEditing: Bool = false
    @State private var isError: Bool = false
    @State private var hideSecuredText: Bool = true

    public init(title: String,
                text: Binding<String>,
                textPlaceholder: String = "",
                footnote: Binding<String>? = nil,
                isDisabled: Bool = false,
                isSecure: Bool = false,
                error: ((_ text: String) -> Bool)? = nil,
                errorMessage: String? = nil
    ) {
        self.title = title
        self.text = text
        self.textPlaceholder = textPlaceholder
        self.footnote = footnote
        self.isDisabled = isDisabled
        self.isSecure = isSecure
        self.error = error
        self.errorMessage = errorMessage
    }

    public var body: some View {
        VStack(
            alignment: .leading,
            spacing: LayoutConstants.VerticalSpacing.withinFormGroup
        ) {
            Text(title)
                .textStyle(.body)
            VStack {
                if isSecure {
                    HStack {
                        if hideSecuredText {
                            SecureField(textPlaceholder, text: text)
                        } else {
                            TextField(textPlaceholder, text: text)
                        }
                        Button(action : { hideSecuredText.toggle() },
                               label: {
                                   Image(systemName: hideSecuredText ? "eye.fill" : "eye.slash.fill")
                                       .foregroundColor(Color.passwordPeekEyeColor)
                               }
                        )
                    }
                } else {
                    TextField(textPlaceholder, text: text) { isEditing in
                        self.isEditing = isEditing
                    }
                    .onReceive(Just(text), perform: { text in
                        if let error = self.error {
                            isError = error(text.wrappedValue)
                        }
                    })
                }
            }
            .textFieldStyle(FormTextFieldStyle(isEditing: isEditing,
                                               isActive: !isDisabled,
                                               isError: isError))
            .disabled(isDisabled)
            if let footnote = self.footnote {
                Text(footnote.wrappedValue)
                    .textStyle(.subheading)
            }
            if isError, let error = errorMessage {
                Text(error)
                    .font(Font(weight: .medium, size: 14))
                    .foregroundColor(Color.borderError)
            }
        }
    }
}

#if DEBUG
struct FormTextFieldGroupDemoView: View {

    var body: some View {
        VStack {
            FormTextFieldGroup(
                title: "My Text Field",
                text: .constant("")
            )
            FormTextFieldGroup(
                title: "My Text Field",
                text: .constant(""),
                textPlaceholder: "Some Placeholder",
                footnote: .constant("Some Footnote")
            )
            FormTextFieldGroup(
                title: "My Text Field",
                text: .constant("Lorem Ipsum"),
                footnote: .constant("Lorem Ipsum")
            )
            FormTextFieldGroup(
                title: "My Secure Text Field",
                text: .constant("Secured Text"),
                isSecure: true
            )
            FormTextFieldGroup(
                title: "My Error Text Field",
                text: .constant("Some Error Text"),
                error: { _ in true },
                errorMessage: "My Error Message"
            )
        }
        .padding()
    }
}

struct FormTextFieldGroup_Previews: PreviewProvider {
    static var previews: some View {
        FormTextFieldGroupDemoView()
            .preferredColorScheme(.light)
        FormTextFieldGroupDemoView()
            .preferredColorScheme(.dark)
    }
}
#endif
