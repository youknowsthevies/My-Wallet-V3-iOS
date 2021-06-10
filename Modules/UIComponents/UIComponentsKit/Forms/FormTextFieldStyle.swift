import SwiftUI

public struct FormTextFieldStyle: TextFieldStyle {

    let paddingInsets: EdgeInsets = EdgeInsets(
        top: 12,
        leading: 12,
        bottom: 12,
        trailing: 12
    )
    let borderWidth: CGFloat = 1
    let isEditing: Bool

    public init(isEditing: Bool = false) {
        // required for exposing the view to the external world
        self.isEditing = isEditing
    }

    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .textStyle(.formField)
            .padding(paddingInsets)
            .background(
                RoundedRectangle(cornerRadius: LayoutConstants.buttonCornerRadious)
                .stroke(isEditing ? Color.borderFocused : Color.borderPrimary,
                        lineWidth: borderWidth)
            )
            .frame(minHeight: LayoutConstants.buttonMinHeight)
    }
}

#if DEBUG
struct FormTextFieldStyleDemoView: View {

    var body: some View {
        VStack {
            TextField("Placeholder", text: .constant(""))
            TextField("Placeholder", text: .constant("Lorem ipsum"))
        }
        .textFieldStyle(FormTextFieldStyle())
        .padding()
    }
}

struct FormTextFieldStyle_Previews: PreviewProvider {
    static var previews: some View {
        FormTextFieldStyleDemoView()
            .preferredColorScheme(.light)
        FormTextFieldStyleDemoView()
            .preferredColorScheme(.dark)
    }
}
#endif
