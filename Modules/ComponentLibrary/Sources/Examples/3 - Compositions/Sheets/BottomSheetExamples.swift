// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

struct BottomSheetExamples: View {

    var body: some View {
        Color.gray
            .overlay(
                BottomSheetView(
                    isPresented: Binding(get: { true }, set: { _ in }),
                    maximumHeight: 70.vh
                ) {
                    ForEach(0..<10) { i in
                        DefaultRow(title: "\(i)", accessoryView: { Icon.chevronRight })
                            .accentColor(.semantic.muted)
                        if i != 9 {
                            Divider()
                        }
                    }
                }
            )
            .ignoresSafeArea()
    }
}
