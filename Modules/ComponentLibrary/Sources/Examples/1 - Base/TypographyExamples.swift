// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

struct TypographyExamplesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(Typography.allTypography, id: \.self) { typography in

                    Text(typography.name)
                        .typography(typography)

                    Text("\(typography.weight.rawValue) \(typography.size.description)")
                        .typography(.caption1)

                    Text(previewText(for: typography))
                        .typography(typography)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 15))

                    PrimaryDivider()
                }
            }
            .padding()
        }
    }

    func previewText(for typography: Typography) -> String {
        switch typography {
        case .bodyMono, .paragraphMono:
            return "0123456789"
        default:
            return "The quick brown fox jumps over the lazy dog"
        }
    }
}

struct TypographyExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        TypographyExamplesView()
    }
}
