// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import ToolKit

public struct PendingStateViewModel {
    public enum Image {
        case triangleError
        case clock
        case region
        case circleError
        case success
        case custom(String, Bundle)

        public var name: String {
            switch self {
            case .circleError:
                return "circular-error-icon"
            case .region:
                return "region-error-icon"
            case .triangleError:
                return "triangle-error-icon"
            case .clock:
                return "clock-error-icon"
            case .success:
                return "v-success-icon"
            case .custom(let name, _):
                return name
            }
        }
    }

    let compositeStatusViewType: CompositeStatusViewType
    let title: NSAttributedString
    let subtitleTextViewModel: InteractableTextViewModel
    let button: ButtonViewModel?
    let supplementaryButton: ButtonViewModel?
    let displayCloseButton: Bool

    /// Steams the url upon each tap
    public var tap: Observable<URL> {
        subtitleTextViewModel
            .tap
            .map(\.url)
    }

    static private func title(_ string: String) -> NSAttributedString {
        NSAttributedString(
            string,
            font: .main(.regular, 20),
            color: .titleText
        )
    }

    public init(compositeStatusViewType: CompositeStatusViewType,
                title: String,
                subtitle: String,
                interactibleText: String? = nil,
                url: String? = nil,
                button: ButtonViewModel? = nil,
                supplementaryButton: ButtonViewModel? = nil,
                displayCloseButton: Bool = false) {
        self.compositeStatusViewType = compositeStatusViewType
        self.title = Self.title(title)
        var inputs: [InteractableTextViewModel.Input] = [.text(string: subtitle)]
        if let interactableText = interactibleText, let url = url {
            inputs.append(.url(string: interactableText, url: url))
        }

        self.subtitleTextViewModel = .init(
            inputs: inputs,
            textStyle: .init(
                color: .descriptionText,
                font: .main(.regular, 14.0)
            ),
            linkStyle: .init(
                color: .primaryButton,
                font: .main(.regular, 14.0
                )
            ),
            alignment: .center
        )
        self.button = button
        self.supplementaryButton = supplementaryButton
        self.displayCloseButton = displayCloseButton
    }
}
