import BlockchainComponentLibrary
import SwiftUI

struct ProgressViewExamples: View {

    @State var progress: Double = 0

    var body: some View {
        VStack {

            Group {
                Text(".linear")
                    .typography(.micro)
                ProgressView(value: progress)
                    .frame(width: 15.vw, height: 15.vh)
                    .progressViewStyle(.linear)
            }

            PrimaryDivider()

            Group {
                Text(".circular")
                    .typography(.micro)
                ProgressView(value: progress)
                    .frame(width: 15.vw, height: 15.vh)
                    .progressViewStyle(.circular)
            }

            PrimaryDivider()

            Group {
                Text(".indeterminate")
                    .typography(.micro)
                HStack {
                    ProgressView(value: progress)
                        .frame(width: 15.vw, height: 15.vh)
                        .progressViewStyle(.indeterminate)

                    ProgressView(value: 0.25)
                        .frame(width: 15.vw, height: 15.vh)
                        .progressViewStyle(.indeterminate)
                }
            }

            PrimaryDivider()

            Group {
                Text(".blockchain")
                    .typography(.micro)
                ProgressView(value: progress)
                    .progressViewStyle(.blockchain)
                    .frame(width: 15.vw, height: 15.vh)
            }
        }
        .onAppear {
            withAnimation(.linear.speed(10)) {
                progress = 1
            }
        }
    }
}
