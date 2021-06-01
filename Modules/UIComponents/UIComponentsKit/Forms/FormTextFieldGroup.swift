import SwiftUI

public struct FormTextFieldGroup: View {

    public let title: String
    public let text: Binding<String>
    public let textPlaceholder: String
    @State public var textFieldStyle: FormTextFieldStyle = FormTextFieldStyle()

    public init(title: String,
                text: Binding<String>,
                textPlaceholder: String = ""
    ) {
        self.title = title
        self.text = text
        self.textPlaceholder = textPlaceholder
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
                textPlaceholder: "Some Placeholder"
            )
            .padding()
            FormTextFieldGroup(
                title: "My Text Field",
                text: .constant("Lorem Ipsum")
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
