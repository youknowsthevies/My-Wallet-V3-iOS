// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct FormAnswer: Codable, Identifiable, Equatable {

    public enum AnswerType: String, Codable {
        case selection = "SELECTION"
        case openEnded = "OPEN_ENDED"
    }

    public let id: String
    public let type: AnswerType
    public let text: String
    public var children: [FormAnswer]?
    public var hint: String?
    public var input: String?
    public var checked: Bool?

    public init(
        id: String,
        type: AnswerType,
        text: String,
        children: [FormAnswer]?,
        input: String?,
        hint: String?,
        checked: Bool?
    ) {
        self.id = id
        self.type = type
        self.text = text
        self.hint = hint
        self.children = children
        self.input = input
        self.checked = checked
    }
}
