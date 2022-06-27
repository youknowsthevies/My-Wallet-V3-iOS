import BlockchainComponentLibrary
import ComposableArchitecture
import ComposableNavigation
import Localization
import SwiftUI
import UIComponentsKit

// TODO: back button in black
// TODO: x icon in red
// TODO: Analytics
// TODO: acessibility identifiers

private typealias LocalizedString = LocalizationConstants.UserDeletion.MainScreen

public struct UserDeletionView: View {
    let store: Store<UserDeletionState, UserDeletionAction>
    @Environment(\.openURL) private var openURL
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var viewStore: ViewStore<UserDeletionState, UserDeletionAction>

    public init(store: Store<UserDeletionState, UserDeletionAction>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    public var body: some View {
        PrimaryNavigationView {
            GeometryReader { (proxy: GeometryProxy) in

                ScrollView {
                    contentView
                        .frame(height: proxy.size.height)
                }
                .navigationRoute(in: store)
                .whiteNavigationBarStyle()
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(LocalizedString.navBarTitle)
                .trailingNavigationButton(.close, action: {
                    presentationMode.wrappedValue.dismiss()
                })
                .onAppear(perform: {
                    viewStore.send(.onAppear)
                })
            }
        }
    }

    private var headerView: some View {
        VStack(spacing: 8) {
            Text(LocalizedString.header.title)
                .typography(.title2)
                .foregroundColor(.textTitle)
            Text(LocalizedString.header.subtitle)
                .typography(.paragraph1)
                .foregroundColor(.textBody)
        }
        .padding(.top, 16)
        .padding(.bottom, 35)
    }

    private var stepsView: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                    .frame(width: 24)

                ImageAsset.iconClose
                    .frame(width: 24, height: 24)

                Text(LocalizedString.bulletPoints.first)
                    .typography(.body2)
                    .foregroundColor(.textTitle)
                    .padding(16)

                Spacer()
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.dividerLineLight)
            )

            HStack {
                Spacer()
                    .frame(width: 24)

                ImageAsset.iconClose
                    .frame(width: 24, height: 24)

                Text(LocalizedString.bulletPoints.second)
                    .typography(.body2)
                    .foregroundColor(.textTitle)
                    .padding(16)

                Spacer()
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.dividerLineLight)
            )
        }
    }

    private var withdrawFundsView: some View {
        AlertCard(
            title: LocalizedString.withdrawBanner.title,
            message: LocalizedString.withdrawBanner.subtitle,
            variant: .warning
        )
    }

    private var footerActionsView: some View {
        VStack {
            PrimaryRow(
                title: LocalizedString.externalLinks.dataRetention,
                trailing: { ImageAsset.iconExternalLink },
                action: {
                    openURL(viewStore.state.externalLinks.dataRetention)
                }
            )
            PrimaryRow(
                title: LocalizedString.externalLinks.needHelp,
                trailing: { ImageAsset.iconExternalLink },
                action: {
                    openURL(viewStore.state.externalLinks.needHelp)
                }
            )
        }
    }

    private var deleteAccountView: some View {
        DestructivePrimaryButton(
            title: LocalizedString.mainCTA,
            action: {
                viewStore.send(.showConfirmationScreen)
            }
        )
    }

    private var contentView: some View {
        VStack(spacing: 8) {

            headerView
            stepsView
            withdrawFundsView

            Spacer()
            footerActionsView
            deleteAccountView
        }
        .padding()
    }
}
