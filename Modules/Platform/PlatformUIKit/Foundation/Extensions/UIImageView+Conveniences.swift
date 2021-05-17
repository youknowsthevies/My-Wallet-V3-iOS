// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift

public struct ImageViewContent {

    public enum RenderingMode {
        case template(Color)
        case normal

        var templateColor: Color? {
            switch self {
            case .template(let color):
                return color
            case .normal:
                return nil
            }
        }
    }

    public static var empty: ImageViewContent {
        .init()
    }

    public var isEmpty: Bool {
        imageName == nil
    }

    var templateColor: UIColor? {
        renderingMode.templateColor
    }

    var image: UIImage? {
        guard let imageName = imageName else { return nil }

        switch renderingMode {
        case .normal:
            return UIImage(named: imageName, in: bundle, compatibleWith: .none)
        case .template:
            let image = UIImage(named: imageName, in: bundle, compatibleWith: .none)
            return image?.withRenderingMode(.alwaysTemplate)
        }
    }

    let imageName: String?
    let accessibility: Accessibility

    private let renderingMode: RenderingMode
    private let bundle: Bundle

    public init(imageName: String? = nil,
                accessibility: Accessibility = .none,
                renderingMode: RenderingMode = .normal,
                bundle: Bundle = .main) {
        self.imageName = imageName
        self.accessibility = accessibility
        self.renderingMode = renderingMode
        self.bundle = bundle
    }
}

extension ImageViewContent: Equatable {
    public static func == (lhs: ImageViewContent, rhs: ImageViewContent) -> Bool {
        lhs.imageName == rhs.imageName &&
               lhs.accessibility == rhs.accessibility &&
               lhs.bundle.bundleIdentifier == rhs.bundle.bundleIdentifier
    }
}

extension UIImageView {
    public func set(_ content: ImageViewContent?) {
        image = content?.image
        tintColor = content?.templateColor
        accessibility = content?.accessibility ?? .none
    }
}

extension Reactive where Base: UIImageView {
    public var content: Binder<ImageViewContent> {
        Binder(base) { imageView, content in
            imageView.set(content)
        }
    }
}
