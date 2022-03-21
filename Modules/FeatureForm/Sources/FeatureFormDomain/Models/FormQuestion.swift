// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct FormQuestion: Codable, Identifiable, Equatable {

    public enum QuestionType: String, Codable {
        case singleSelection = "SINGLE_SELECTION"
        case multipleSelection = "MULTIPLE_SELECTION"
    }

    public let id: String
    public let type: QuestionType
    public let isDropdown: Bool?
    public let text: String
    public let instructions: String?
    public var children: [FormAnswer]

    public init(
        id: String,
        type: QuestionType,
        isDropdown: Bool?,
        text: String,
        instructions: String?,
        children: [FormAnswer]
    ) {
        self.id = id
        self.type = type
        self.isDropdown = isDropdown
        self.text = text
        self.instructions = instructions
        self.children = children
    }
}
