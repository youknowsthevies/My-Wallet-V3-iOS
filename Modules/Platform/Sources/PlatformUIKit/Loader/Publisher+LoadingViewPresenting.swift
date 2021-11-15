// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

extension Publisher {

    /// Shows a loading indicator when the publisher is subscribed to and hides it when receiving an output, on completion (e.g. to handle errors) or on cancellations.
    /// - Parameters:
    ///   - loadingViewPresenter: the loading view presenter to be used for this operation
    ///   - style: The style of the loading indicator to be shown. Defaults to `circle`
    ///   - text: An optional message to display alongside the activity indicator.
    /// - Returns: A `Combine.Publisher` that handles the upstream's events.
    public func handleLoaderForLifecycle(
        loader loadingViewPresenter: LoadingViewPresenting,
        style: LoadingViewPresenter.LoadingViewStyle = .circle,
        text: String? = nil
    ) -> Publishers.HandleEvents<Self> {
        handleEvents(
            receiveSubscription: { [loadingViewPresenter] _ in
                loadingViewPresenter.show(with: style, text: text)
            }, receiveOutput: { [loadingViewPresenter] _ in
                if loadingViewPresenter.isVisible {
                    loadingViewPresenter.hide()
                }
            }, receiveCompletion: { [loadingViewPresenter] _ in
                if loadingViewPresenter.isVisible {
                    loadingViewPresenter.hide()
                }
            }, receiveCancel: { [loadingViewPresenter] in
                if loadingViewPresenter.isVisible {
                    loadingViewPresenter.hide()
                }
            }
        )
    }
}
