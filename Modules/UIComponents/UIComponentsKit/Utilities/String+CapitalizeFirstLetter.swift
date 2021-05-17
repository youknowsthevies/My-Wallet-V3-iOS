// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension String {

    var capitalizeFirstLetter: String {
        prefix(1).capitalized + dropFirst()
    }

    mutating func capitalingFirstLetter() {
        self = self.capitalizeFirstLetter
    }
}
