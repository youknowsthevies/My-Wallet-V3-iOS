import BlockchainComponentLibrary
import SwiftUI

struct GIFExamples: View {

    @State var url: String = "https://mailfloss.com/wp-content/uploads/2019/08/5d667832888ec_gif1-Everyonelovesgifs_4ef1dbef8a604a3e1b26eebf2c000ef0.gif"

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 0) {
                TextField("URL", text: $url)
                    .typography(.micro)
                    .padding()
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color.semantic.light, lineWidth: 1)
                    )
                if let url = url {
                    AsyncMedia(
                        url: URL(string: url),
                        placeholder: { ProgressView().progressViewStyle(.circular) }
                    )
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 90.pmin, in: geometry.frame(in: .global))
                }
            }
        }
    }
}
