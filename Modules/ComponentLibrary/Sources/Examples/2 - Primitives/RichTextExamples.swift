// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

struct RichTextExamples: View {
    @State var text: String = """
    ## Markdown
    The *quick* brown _fox_ **jumps** over the lazy dog.
    [https://blockchain.com](Links) get styling, but no tap action.
    """

    var body: some View {
        VStack(spacing: 0) {
            TextEditor(text: $text)
                .frame(height: 50.ph)

            RichText(text) // or `Text(rich:)`
                .typography(.body1)
        }
    }
}

struct RichTextExamples_Previews: PreviewProvider {
    static var previews: some View {
        RichTextExamples()
    }
}
