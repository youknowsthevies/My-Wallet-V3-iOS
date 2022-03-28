import BlockchainComponentLibrary
import ComposableArchitecture
import Localization
import SwiftUI
import UIComponentsKit

protocol SupportViewViewDelegate: AnyObject {
    func didTapViewFAQs()
    func didTapContactUs()
}

struct SupportView: View {

    private typealias LocalizationIds = LocalizationConstants.Authentication.Support

    weak var delegate: SupportViewViewDelegate?
    private let store: Store<SupportViewState, SupportViewAction>

    init(
        store: Store<SupportViewState, SupportViewAction>
    ) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            ActionableView(buttons: [
                .init(
                    title: LocalizationIds.contactUs,
                    action: { [delegate] in
                        delegate?.didTapContactUs()
                    },
                    style: .secondary
                ),
                .init(
                    title: LocalizationIds.viewFAQ,
                    action: { [delegate] in
                        delegate?.didTapViewFAQs()
                    },
                    style: .secondary
                )
            ], content: {
                VStack(alignment: .leading, spacing: 10.0, content: {
                    Text(LocalizationIds.title)
                        .typography(.title3)
                    Text(LocalizationIds.description)
                        .typography(.paragraph1)
                })
            })
            .padding(16.0)
            .fixedSize(horizontal: false, vertical: true)
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
