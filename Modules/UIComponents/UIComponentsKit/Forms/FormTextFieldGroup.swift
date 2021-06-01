import SwiftUI

public struct FormTextFieldGroup: View {

    public let title: String
    public let text: Binding<String>
    public let textPlaceholder: String
    public let footnote: String
    @State public var textFieldStyle: FormTextFieldStyle = FormTextFieldStyle()

    public init(title: String,
                text: Binding<String>,
                textPlaceholder: String = "",
                footnote: String = ""
    ) {
        self.title = title
        self.text = text
        self.textPlaceholder = textPlaceholder
        self.footnote = footnote
    }

    public var body: some View {
        VStack(
            alignment: .leading,
            spacing: LayoutConstants.VerticalSpacing.withinFormGroup
        ) {
            Text(title)
                .textStyle(.body)
            TextField(textPlaceholder, text: text) { isEditing in
                if isEditing {
                    textFieldStyle = FormTextFieldStyle(isEditing: true)
                } else {
                    textFieldStyle = FormTextFieldStyle()
                }
            }
            .textFieldStyle(textFieldStyle)
            Text(footnote)
                .textStyle(.subheading)
        }
    }
}

#if DEBUG
struct FormTextFieldGroupDemoView: View {

    var body: some View {
        VStack {
            FormTextFieldGroup(
                title: "My Text Field",
                text: .constant(""),
                footnote: "My Footnote"
            )
            .padding()
            FormTextFieldGroup(
                title: "My Text Field",
                text: .constant(""),
                textPlaceholder: "Some Placeholder",
                footnote: "My Footnote"
            )
            .padding()
            FormTextFieldGroup(
                title: "My Text Field",
                text: .constant("Lorem Ipsum"),
                footnote: "My Footnote"
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
