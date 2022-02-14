// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformKit
import PlatformUIKit
import SwiftUI
import ToolKit
import UIComponentsKit

protocol CustomerSupportChatRouterAPI {
    func start()
}

final class CustomerSupportChatRouter: CustomerSupportChatRouterAPI {

    private let chatService: CustomerSupportChatServiceAPI
    private let topMostViewControllerProvider: TopMostViewControllerProviding
    private var cancellables = Set<AnyCancellable>()

    init(
        chatService: CustomerSupportChatServiceAPI = resolve(),
        topMostViewControllerProvider: TopMostViewControllerProviding = resolve()
    ) {
        self.chatService = chatService
        self.topMostViewControllerProvider = topMostViewControllerProvider
    }

    func start() {
        showCustomerSupportChat()
    }

    private func showCustomerSupportChat() {
        chatService.presentMessagingScreen()
    }
}
