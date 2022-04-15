//
//  NotificationSettingsActivityTogglesViewView.swift
//  FeatureBuilder
//
//  Created by Augustin Udrea on 12/04/2022.
//

import BlockchainComponentLibrary
import ComposableArchitecture
import SwiftUI

struct NotificationSettingsDetailsView: View {
    var store: Store<NotificationSettingsDetailsState, NotificationSettingsDetailsAction>
    @ObservedObject var viewStore: ViewStore<NotificationSettingsDetailsState, NotificationSettingsDetailsAction>

    init(store: Store<NotificationSettingsDetailsState, NotificationSettingsDetailsAction>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        Text("Placeholder")
    }
}
