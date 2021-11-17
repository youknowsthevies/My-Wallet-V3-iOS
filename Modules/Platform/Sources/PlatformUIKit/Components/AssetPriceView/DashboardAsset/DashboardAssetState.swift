// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitectureExtensions
import Foundation

extension DashboardAsset.State {

    /// The state of the `AssetPrice` interactor and presenter
    public enum AssetPrice {
        public typealias Interaction = LoadingState<DashboardAsset.Value.Interaction.AssetPrice>
        public typealias Presentation = LoadingState<DashboardAsset.Value.Presentation.AssetPrice>
    }
}
