import Combine
import SwiftUI

public struct FormTextFieldGroup: View {

    public var title: String
    public let text: Binding<String>
    public let textPlaceholder: String
    public let footnote: String?
    public let isDisabled: Bool
    public let isSecure: Bool
    public let isSecureFieldFocused: Binding<Bool>
    public let error: ((_ text: String) -> Bool)?
    public let errorMessage: String?
    public var resetFocus: (() -> Void)?
    @State private var isFocused: Bool = false
    @State private var isError: Bool = false

    public init(
        title: String,
        text: Binding<String>,
        textPlaceholder: String = "",
        footnote: String? = nil,
        isDisabled: Bool = false,
        isSecure: Bool = false,
        isSecureFieldFocused: Binding<Bool> = .constant(false),
        error: ((_ text: String) -> Bool)? = nil,
        errorMessage: String? = nil,
        resetFocus: (() -> Void)? = nil
    ) {
        self.title = title
        self.text = text
        self.textPlaceholder = textPlaceholder
        self.footnote = footnote
        self.isDisabled = isDisabled
        self.isSecure = isSecure
        self.isSecureFieldFocused = isSecureFieldFocused
        self.error = error
        self.errorMessage = errorMessage
        self.resetFocus = resetFocus
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
                    ViewableSecureField(
                        text: text,
                        textPlaceholder: textPlaceholder
                    )
                    .onTapGesture { resetFocus?() }
                    .onReceive(Just(isSecureFieldFocused), perform: { isFocused in
                        self.isFocused = isFocused.wrappedValue
                    })
                } else {
                    TextField(textPlaceholder, text: text) { isEditing in
                        if isEditing {
                            resetFocus?()
                        }
                        self.isFocused = isEditing
                    }
                }
            }
            .onReceive(Just(text), perform: { text in
                if let error = self.error {
                    isError = error(text.wrappedValue)
                }
            })
            .textFieldStyle(FormTextFieldStyle(
                isEditing: isFocused,
                isActive: !isDisabled,
                isError: isError
            ))
            .disabled(isDisabled)

            if let footnote = self.footnote {
                Text(footnote)
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

struct ViewableSecureField: View {

    private let text: Binding<String>
    private let textPlaceholder: String
    @State private var hideSecuredText: Bool = true

    init(
        text: Binding<String>,
        textPlaceholder: String
    ) {
        self.text = text
        self.textPlaceholder = textPlaceholder
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            if hideSecuredText {
                SecureField(textPlaceholder, text: text)
            } else {
                TextField(textPlaceholder, text: text)
            }
            Button(
                action: { hideSecuredText.toggle() },
                label: {
                    Image(systemName: hideSecuredText ? "eye.fill" : "eye.slash.fill")
                        .foregroundColor(Color.passwordPeekEyeColor)
                }
            )
            .padding(.trailing, 15)
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
                footnote: "Some Footnote"
            )
            FormTextFieldGroup(
                title: "My Text Field",
                text: .constant("Lorem Ipsum"),
                footnote: "Lorem Ipsum"
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
