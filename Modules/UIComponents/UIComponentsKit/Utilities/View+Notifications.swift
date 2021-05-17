// Original Source: https://www.swiftbysundell.com/tips/observing-combine-publishers-in-swiftui-views/

import SwiftUI

extension View {

    public func onNotification(
        _ notificationName: Notification.Name,
        perform action: @escaping () -> Void
    ) -> some View {
        onReceive(NotificationCenter.default.publisher(
            for: notificationName
        )) { _ in
            action()
        }
    }

    public func onAppEnteredBackground(
        perform action: @escaping () -> Void
    ) -> some View {
        onNotification(
            UIApplication.didEnterBackgroundNotification,
            perform: action
        )
    }

    public func onAppEnteredForeground(
        perform action: @escaping () -> Void
    ) -> some View {
        onNotification(
            UIApplication.willEnterForegroundNotification,
            perform: action
        )
    }
}
