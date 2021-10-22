// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ComponentLibrary
import SwiftUI

struct GridExamplesView: View {

    var body: some View {
        ScrollView {
            VStack {

                // MARK: - HStack

                Text("HStack").typography(.title3)

                GridReader(layout: .two, width: CGRect.screen.width) { grid in
                    HStack(spacing: grid.gutter) {
                        Sample(text: "Column 1")
                            .frame(width: grid.columnWidth)

                        Sample(text: "Column 2")
                            .frame(width: grid.columnWidth)
                    }
                    .padding(grid.padding)
                }
                .background(Color.gray.opacity(0.1))

                // MARK: - LazyVGrid

                Text("LazyVGrid").typography(.title3)

                GridReader(layout: .two, width: CGRect.screen.width) { grid in
                    LazyVGrid(columns: grid.items, spacing: grid.gutter) {
                        Sample(text: "Column 1")
                        Sample(text: "Column 2")

                        Sample(text: "Row 2, Column 1")
                        Sample(text: "Row 2, Column 2")
                    }
                    .padding(grid.padding)
                }
                .background(Color.gray.opacity(0.1))
            }
        }
    }

    struct Sample: View {
        let text: String

        var body: some View {
            ZStack {
                Rectangle()
                    .fill(Color.red.opacity(0.1))

                Text(text)
            }
        }
    }
}

struct GridExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        GridExamplesView()
    }
}
