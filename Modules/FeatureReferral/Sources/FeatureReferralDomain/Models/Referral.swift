// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct Referral: Equatable, Hashable, Decodable {
    public var code: String
    public var rewardTitle: String
    public var rewardSubtitle: String
    public var steps: [Step]

    public init(code: String, rewardTitle: String, rewardSubtitle: String, steps: [Step]) {
        self.code = code
        self.rewardTitle = rewardTitle
        self.rewardSubtitle = rewardSubtitle
        self.steps = steps
    }
}

public struct Step: Identifiable, Equatable, Hashable, Decodable {
    public var id = UUID()
    public let text: String

    public init(id: UUID = UUID(), text: String) {
        self.id = id
        self.text = text
    }
}
