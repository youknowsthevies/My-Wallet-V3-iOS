// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureSettingsDomain
import PlatformKit
import RxSwift

final class ConnectSectionPresenter: SettingsSectionPresenting {

    typealias State = SettingsSectionLoadingState

    let sectionType: SettingsSectionType = .connect

    var state: Observable<State> {
        let presenter = PITConnectionCellPresenter()
        let state = State.loaded(next:
            .some(
                .init(
                    sectionType: sectionType,
                    items: [.init(cellType: .badge(.pitConnection, presenter))]
                )
            )
        )

        return .just(state)
    }

    init() {}
}
