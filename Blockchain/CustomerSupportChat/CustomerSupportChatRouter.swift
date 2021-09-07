// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformKit
import PlatformUIKit
import SwiftUI
import ToolKit

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
        guard let top = topMostViewControllerProvider.topMostViewController else {
            fatalError("Expected a UIViewController")
        }
        let departmentSelectionView = CustomerSupportDepartmentSelector(selection: { [weak self] department in
            guard let self = self else { return }
            self.dismissTopMost(weak: self) { (self) in
                self.showCustomerSupportChatForDepartment(department)
            }
        })

        let hostingController = UIHostingController(rootView: departmentSelectionView)
        top.present(hostingController, animated: true, completion: nil)
    }

    private func showCustomerSupportChatForDepartment(_ department: CustomerSupportDepartment) {
        chatService
            .buildMessagingScreenForDepartment(department)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    Logger.shared.error("Error initializing messaging screen: \(error)")
                }
            } receiveValue: { [topMostViewControllerProvider] viewController in
                guard let top = topMostViewControllerProvider.topMostViewController else {
                    fatalError("Expected a viewController")
                }
                top.present(viewController, animated: true, completion: nil)
            }
            .store(in: &cancellables)
    }

    private func dismissTopMost(
        weak object: CustomerSupportChatRouter,
        _ selector: @escaping (CustomerSupportChatRouter) -> Void
    ) {
        guard let viewController = topMostViewControllerProvider.topMostViewController else {
            selector(object)
            return
        }
        viewController.dismiss(animated: true, completion: {
            selector(object)
        })
    }
}
