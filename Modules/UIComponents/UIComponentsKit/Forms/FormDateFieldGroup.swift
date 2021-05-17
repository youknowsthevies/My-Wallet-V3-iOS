import SwiftUI

public struct FormDateFieldGroup: View {

    public let title: String
    public let date: Binding<Date>

    public init(title: String, date: Binding<Date>) {
        self.title = title
        self.date = date
    }

    public var body: some View {
        VStack(
            alignment: .leading,
            spacing: LayoutConstants.VerticalSpacing.withinFormGroup
        ) {
            DatePicker(
                selection: date,
                displayedComponents: [.date]
            ) {
                Text(title)
                    .textStyle(.body)
            }
        }
    }
}

#if DEBUG
struct FormDateFieldGroupDemoView: View {

    @State private var date: Date = .init()

    var body: some View {
        FormDateFieldGroup(title: "My Date Field", date: $date)
            .padding()
    }
}

struct FormDateFormFieldGroup_Previews: PreviewProvider {
    static var previews: some View {
        FormDateFieldGroupDemoView()
            .preferredColorScheme(.light)
        FormDateFieldGroupDemoView()
            .preferredColorScheme(.dark)
    }
}
#endif
