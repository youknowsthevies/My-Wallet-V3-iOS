// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// A sample SwiftUI view for testing SPM package dependency
public struct SampleView: View {

    public init() {}

    public var body: some View {
        Text("Hello World!")
    }
}

struct SampleView_Previews: PreviewProvider {
    static var previews: some View {
        SampleView()
    }
}
