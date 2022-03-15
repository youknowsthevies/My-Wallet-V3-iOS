import ComposableArchitecture
import Localization
import SwiftUI
import UIComponentsKit

struct SupportView: View {

    private typealias LocalizationIds = LocalizationConstants.Authentication.Support

    private let store: Store<SupportViewState, SupportViewAction>

    init(store: Store<SupportViewState, SupportViewAction>) {
        self.store = store
    }

    var body: some View {
        ActionableView(buttons: [
            .init(
                title: LocalizationIds.emailUs,
                action: {

                },
                style: .secondary
            ),
            .init(
                title: LocalizationIds.viewFAQ,
                action: {

                },
                style: .secondary
            )
        ], content: {
            VStack(spacing: 10.0, content: {
                Text(LocalizationIds.title)
                    .typography(.title3)
                Text(LocalizationIds.description)
                    .typography(.paragraph1)
            })
        })
    }
}

//struct SupportView_Previews: PreviewProvider {
//    static var previews: some View {
//        SupportView()
//    }
//}
