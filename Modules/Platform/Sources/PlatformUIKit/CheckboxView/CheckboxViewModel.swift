// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxDataSources
import RxSwift

public final class CheckboxViewModel: IdentifiableType {

    // MARK: - Public Properties

    public let image: Driver<UIImage?>

    public let labelContent: Driver<LabelContent>

    public let selectedRelay = BehaviorRelay<Bool>(value: false)

    // MARK: - RxDataSources

    public let identity: AnyHashable

    // MARK: - Init

    public init(
        text: String
    ) {
        identity = text
        labelContent = .just(
            .init(
                text: text,
                font: .main(.medium, 12.0),
                color: .textFieldText
            )
        )
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
}

extension CheckboxViewModel: Equatable {
    public static func == (lhs: CheckboxViewModel, rhs: CheckboxViewModel) -> Bool {
        lhs.identity == rhs.identity &&
            lhs.selectedRelay.value == rhs.selectedRelay.value
    }
}
