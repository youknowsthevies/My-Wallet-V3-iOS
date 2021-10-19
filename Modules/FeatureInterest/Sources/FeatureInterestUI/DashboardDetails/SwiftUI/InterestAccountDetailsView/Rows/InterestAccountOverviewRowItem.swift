// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct InterestAccountOverviewRowItem: Equatable, Identifiable {

    var id: String {
        title + description
    }

    let title: String
    let description: String
}
