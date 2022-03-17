import BlockchainComponentLibrary
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
        WithViewStore(store) { viewStore in
            VStack(spacing: 40.0) {
                VStack(spacing: 24.0) {
                    VStack(alignment: .leading, spacing: 10.0, content: {
                        Text(LocalizationIds.title)
                            .typography(.title3)
                        Text(LocalizationIds.description)
                            .typography(.paragraph1)
                        VStack(alignment: .center, spacing: 16.0) {
                            MinimalDoubleButton(
                                leadingTitle: LocalizationIds.chatNow,
                                leadingAction: {

                                },
                                trailingTitle: LocalizationIds.emailUs,
                                trailingAction: {

                                }
                            )
                        }
                    })
                }
                .padding(24.0)
            }
            .onAppear {
                viewStore.send(.loadAppStoreVersionInformation)
            }
        }
    }
}

//struct SupportView_Previews: PreviewProvider {
//    static var previews: some View {
//        SupportView()
//    }
//}
