import SwiftUI

public struct FormTextFieldGroup: View {

    public let title: String
    public let text: Binding<String>
    public let textPlaceholder: String
    public let footnote: Binding<String>?
    public let isDisabled: Bool
    public let isSecure: Bool
    @State private var isEditing: Bool = false
    @State private var hideSecuredText: Bool = true

    public init(title: String,
                text: Binding<String>,
                textPlaceholder: String = "",
                footnote: Binding<String>? = nil,
                isDisabled: Bool = false,
                isSecure: Bool = false
    ) {
        self.title = title
        self.text = text
        self.textPlaceholder = textPlaceholder
        self.footnote = footnote
        self.isDisabled = isDisabled
        self.isSecure = isSecure
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
                            Button(action : { hideSecuredText.toggle() }) {
                                Image(systemName: "eye.fill")
                                    .foregroundColor(Color.passwordPeekEyeColor)
                            }
                        } else {
                            TextField(textPlaceholder, text: text)
                            Button(action: { hideSecuredText.toggle() }) {
                                Image(systemName: "eye.slash.fill")
                                    .foregroundColor(Color.passwordPeekEyeColor)
                            }
                        }
                    }
                } else {
                    TextField(textPlaceholder, text: text) { isEditing in
                        self.isEditing = isEditing
                    }
                }
            }
            .textFieldStyle(FormTextFieldStyle(isEditing: isEditing, isActive: !isDisabled))
            .disabled(isDisabled)
            if let footnote = self.footnote {
                Text(footnote.wrappedValue)
                    .textStyle(.subheading)
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
            .padding()
            FormTextFieldGroup(
                title: "My Text Field",
                text: .constant(""),
                textPlaceholder: "Some Placeholder",
                footnote: .constant("Some Footnote")
            )
            .padding()
            FormTextFieldGroup(
                title: "My Text Field",
                text: .constant("Lorem Ipsum"),
                footnote: .constant("Lorem Ipsum")
            )
            .padding()
            FormTextFieldGroup(
                title: "My Secure Text Field",
                text: .constant("Secured Text"),
                isSecure: true
            )
            .padding()
        }
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
