// Copyright © Blockchain Luxembourg S.A. All rights reserved.
import SwiftUI

/// Filter view.
/// The Filter can be initialized with any number of items,
/// and a selection parameter, which indicates the initial selection state.
/// A tap on the view changes the selection state to the next item.
///
/// # Figma
///
/// [Filter](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=209%3A11327)
public struct Filter<Selection: Hashable>: View {

    private var items: [Item]

    @Binding private var selection: Selection
    @Environment(\.layoutDirection) private var layoutDirection

    /// Create a Filter view with any number of items and a selection state.
    /// - Parameter items: Items who represents the buttons inside the filter
    /// - Parameter selection: Binding for `selection` from `items` for the currently selected item.
    public init(
        items: [Item],
        selection: Binding<Selection>
    ) {
        self.items = items
        _selection = selection
    }

    public var body: some View {
        HStack(spacing: 8) {
            ForEach(items) { item in
                Text(item.title)
                    .typography(.paragraph2)
                    .foregroundColor(
                        selection == item.identifier ? .semantic.primary : .semantic.muted
                    )
                    .padding(.vertical, 5)
                    .padding(.horizontal, 1)
                    .contentShape(Rectangle())
            }
        }
        .padding(8)
        .contentShape(Rectangle())
        .onTapGesture {
            moveSelection()
        }
    }

    private func moveSelection() {
        guard var index = (items.firstIndex { item in
            item.identifier == selection
        }) else { return }
        index = index == items.count - 1 ? 0 : index + 1
        selection = items[index].identifier
    }
}

extension Filter {

    public struct Item: Identifiable {

        let title: String
        let identifier: Selection

        public var id: Selection { identifier }

        /// Create an Item which is the element to pass into the Filter,
        /// as a representation for the buttons to be shown on the control.
        /// The parameters defined on the items are the data used to display a button.
        /// - Parameter title: title of the item, will be the title of the button
        /// - Parameter identifier: unique identifier which is used to determine which button is on the selected state. The identifier must to be set in order for the control to work with unique elements.
        public init(
            title: String,
            identifier: Selection
        ) {
            self.title = title
            self.identifier = identifier
        }
    }
}

struct Filter_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            PreviewController(
                items: [
                    Filter.Item(title: "Leading", identifier: "leading"),
                    Filter.Item(title: "Trailing", identifier: "trailing")
                ],
                selection: "leading"
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Filter")

            PreviewController(
                items: [
                    Filter.Item(title: "Leading", identifier: "leading"),
                    Filter.Item(title: "Trailing", identifier: "trailing")
                ],
                selection: "trailing"
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Filter with initial selection")

            PreviewController(
                items: [
                    Filter.Item(title: "USD", identifier: "USD"),
                    Filter.Item(title: "GBP", identifier: "GBP"),
                    Filter.Item(title: "EUR", identifier: "EUR")
                ],
                selection: "USD"
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Multi items")
        }
        .padding()
    }

    struct PreviewController<Selection: Hashable>: View {
        let items: [Filter<Selection>.Item]
        @State var selection: Selection

        init(
            items: [Filter<Selection>.Item],
            selection: Selection
        ) {
            self.items = items
            _selection = State(initialValue: selection)
        }

        var body: some View {
            Filter(
                items: items,
                selection: $selection
            )
            .background(Color.semantic.light)
        }
    }
}
