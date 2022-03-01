// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension AsyncSequence {

    public var first: Element? {
        get async throws {
            for try await o in self {
                return o
            }
            return nil
        }
    }
}
