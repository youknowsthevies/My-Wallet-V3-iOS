// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxDataSources

public enum DetailCellPresenter: IdentifiableType, Equatable {

    public typealias Identity = String

    public var identity: String {
        switch self {
        case .buttons(let viewModels):
            return viewModels
                .map(\.textRelay)
                .map(\.value)
                .joined()
        case .currentBalance(let presenter):
            return presenter.identifier
        case .footer(let presenter):
            return presenter.identifier
        case .lineItem(let presenter):
            return presenter.identifier
        }
    }

    public enum LineItemType {
        public var identifier: String {
            switch self {
            case .default(let presenter):
                return presenter.identifier
            }
        }

        case `default`(DefaultLineItemCellPresenter)
    }

    case currentBalance(CurrentBalanceCellPresenter)
    case buttons([ButtonViewModel])
    case footer(FooterTableViewCellPresenter)
    case lineItem(LineItemType)
}

extension DetailCellPresenter {
    public static func == (lhs: DetailCellPresenter, rhs: DetailCellPresenter) -> Bool {
        switch (lhs, rhs) {
        case (.buttons(let left), .buttons(let right)):
            return left.count == right.count
        case (.currentBalance(let left), .currentBalance(let right)):
            return left.identifier == right.identifier
        case (.footer(let left), .footer(let right)):
            return left.identifier == right.identifier
        case (.lineItem(let left), .lineItem(let right)):
            switch (left, right) {
            case (.default(let left), .default(let right)):
                return left.identifier == right.identifier
            }
        default:
            return false
        }
    }
}
