//
//  NotificationSettingsActivityTogglesViewView.swift
//  FeatureBuilder
//
//  Created by Augustin Udrea on 12/04/2022.
//

import SwiftUI
import ComposableArchitecture
import BlockchainComponentLibrary

struct NotificationSettingsDetailsView: View {
    var store: Store<NotificationSettingsDetailsState, NotificationSettingsDetailsAction>
    @ObservedObject var viewStore: ViewStore<NotificationSettingsDetailsState, NotificationSettingsDetailsAction>
    
    init(store: Store<NotificationSettingsDetailsState, NotificationSettingsDetailsAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }
    
    var body: some View {
        Text("Placeholder")
    }
}
