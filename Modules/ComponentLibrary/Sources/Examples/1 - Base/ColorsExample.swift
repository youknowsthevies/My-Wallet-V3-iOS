// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

struct ColorsExamplesView: View {

    struct ColorMap: Identifiable {
        let color: Color
        let name: String
        var id: String { name }
    }

    let allColors: [ColorMap] = [
        ColorMap(color: .semantic.title, name: "title"),
        ColorMap(color: .semantic.body, name: "body"),
        ColorMap(color: .semantic.overlay, name: "overlay"),
        ColorMap(color: .semantic.muted, name: "muted"),
        ColorMap(color: .semantic.dark, name: "dark"),
        ColorMap(color: .semantic.medium, name: "medium"),
        ColorMap(color: .semantic.light, name: "light"),
        ColorMap(color: .semantic.background, name: "background"),
        ColorMap(color: .semantic.primary, name: "primary"),
        ColorMap(color: .semantic.success, name: "success"),
        ColorMap(color: .semantic.warning, name: "warning"),
        ColorMap(color: .semantic.error, name: "error"),
        ColorMap(color: .semantic.blueBG, name: "blueBG"),
        ColorMap(color: .semantic.greenBG, name: "greenBG"),
        ColorMap(color: .semantic.orangeBG, name: "orangeBG"),
        ColorMap(color: .semantic.redBG, name: "redBG")
    ]

    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: [GridItem(), GridItem()], spacing: 8) {
                ForEach(allColors) {
                    swatch(color: $0.color, name: $0.name)
                }
            }
            .padding(12)
        }
    }

    @ViewBuilder func swatch(color: Color, name: String) -> some View {
        VStack {
            Rectangle()
                .fill(color)
                .frame(height: 120)
            Text(name)
                .lineLimit(1)
                .padding()
                .truncationMode(.tail)
                .foregroundColor(.semantic.title)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.semantic.dark, lineWidth: 0.5)
        )
    }
}

struct ColorsExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        ColorsExamplesView()
    }
}
