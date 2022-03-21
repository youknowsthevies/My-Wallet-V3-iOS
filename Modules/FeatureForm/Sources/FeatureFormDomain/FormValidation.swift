// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension FormQuestion {

    var isValid: Bool {
        let isValid: Bool
        switch type {
        case .singleSelection:
            let selections = children.filter { $0.checked == true }
            isValid = selections.count == 1 && selections.hasAllValidAnswers
        case .multipleSelection:
            let selections = children.filter { $0.checked == true }
            isValid = selections.count >= 1 && selections.hasAllValidAnswers
        }
        return isValid
    }
}

extension FormAnswer {

    var isValid: Bool {
        var isValid = checked == true || input?.isEmpty == false
        if let children = children {
            isValid = isValid && children.hasAllValidAnswers
        }
        return isValid
    }
}

extension Array where Element == FormAnswer {

    var hasAllValidAnswers: Bool {
        for element in self {
            guard element.isValid else {
                return false
            }
        }
        return true
    }
}

extension Array where Element == FormQuestion {

    public var isValidForm: Bool {
        for element in self {
            guard element.isValid else {
                return false
            }
        }
        return true
    }
}
