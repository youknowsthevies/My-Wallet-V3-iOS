// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

protocol SendXLMInterface: class {
    typealias PresentationUpdate = SendLumensViewController.PresentationUpdate

    func apply(updates: [PresentationUpdate])
    func present(viewController: UIViewController)
}
