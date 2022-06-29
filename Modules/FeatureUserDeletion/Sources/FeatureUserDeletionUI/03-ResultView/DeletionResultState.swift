import SwiftUI

public struct DeletionResultState: Equatable {
    var success: Bool

    public init(success: Bool) {
        self.success = success
    }
}
