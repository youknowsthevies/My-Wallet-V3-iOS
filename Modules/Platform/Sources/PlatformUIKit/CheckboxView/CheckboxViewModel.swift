// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxDataSources
import RxSwift

public final class CheckboxViewModel: IdentifiableType {

    struct Content {
        let title: String

        static let empty: Content = .init(title: "")
    }

    // MARK: - Public Properties

    public let image: Driver<UIImage?>

    public var labelContent: Driver<LabelContent> {
        contentRelay
            .map(\.title)
            .map {
                .init(
                    text: $0,
                    font: .main(.medium, 12.0),
                    color: .textFieldText
                )
            }
            .asDriver(onErrorJustReturn: .empty)
    }

    public let selectedRelay = BehaviorRelay<Bool>(value: false)

    // MARK: - RxDataSources

    public var identity: AnyHashable {
        contentRelay.value.title
    }

    // MARK: - Private Properties

    private let contentRelay = BehaviorRelay<Content>(value: .empty)

    // MARK: - Init

    public init() {
        image = selectedRelay
            .asObservable()
            .map { $0 ? "checkbox-on" : "checkbox-off" }
            .asDriver(onErrorJustReturn: nil)
            .map { name in
                if let name = name {
                    return UIImage(named: name, in: .UIComponents, compatibleWith: nil)
                }
                return nil
            }
    }

    public func apply(text: String) {
        contentRelay.accept(.init(title: text))
    }
}

extension CheckboxViewModel: Equatable {
    public static func == (lhs: CheckboxViewModel, rhs: CheckboxViewModel) -> Bool {
        lhs.identity == rhs.identity &&
            lhs.selectedRelay.value == rhs.selectedRelay.value
    }
}
