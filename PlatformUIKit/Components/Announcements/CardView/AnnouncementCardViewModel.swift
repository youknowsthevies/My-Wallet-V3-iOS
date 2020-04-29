//
//  AnnouncementCardViewModel.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 26/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import ToolKit
import PlatformKit

/// An announcement card view model
public final class AnnouncementCardViewModel {

    // MARK: - Types

    public typealias DidAppear = () -> Void
    
    /// The priority under which the announcement should show
    public enum Priority {
        case high
        case low
    }
    
    /// The style of the background
    public struct Background {

        /// A blank white background. a computed property.
        public static var white: Background {
            return Background(color: .white)
        }
        
        /// The background color
        let color: UIColor
        
        /// The background image
        let imageName: String?

        /// Computes the `UIImage` out of `imageName`
        var image: UIImage? {
            guard let imageName = imageName else { return nil }
            return UIImage(named: imageName)
        }
        
        public init(color: UIColor = .clear, imageName: String? = nil) {
            self.imageName = imageName
            self.color = color
        }
    }
    
    /// The border style of the card
    public enum Border {
        
        /// Round corners with radius value
        case roundCorners(_ radius: CGFloat)
        
        /// Separator
        case bottomSeparator(_ color: UIColor)
        
        /// No border
        case none
    }
    
    /// The alignment of the content
    public enum Alignment {
        
        /// Natual alignment (leading -> trailing)
        case natural
        
        /// Center alignment
        case center
        
    }
    
    /// The image descriptor
    public struct Image {
        let name: String
        let size: CGSize
        let tintColor: UIColor?
        let bundle: Bundle
        
        var uiImage: UIImage? {
            UIImage(named: name, in: bundle, compatibleWith: .none)
                .map {
                    if tintColor != nil {
                        return $0.withRenderingMode(.alwaysTemplate)
                    }
                    return $0
                }
        }
        
        public init(name: String,
                    size: CGSize = CGSize(width: 40, height: 40),
                    tintColor: UIColor? = nil,
                    bundle: Bundle = .main) {
            self.name = name
            self.size = size
            self.tintColor = tintColor
            self.bundle = bundle
        }
    }
    
    /// The dismissal state of the card announcement
    public enum DismissState {
        
        public typealias Action = () -> Void

        /// Indicates the announcement is dismissable and the associated `Action`
        /// is should be executed upon dismissal
        case dismissible(Action)
        
        /// Indicates the announcement is not dismissable. Therefore `X` button is hidden.
        case undismissible
    }
    
    /// The presentation type of the card
    public enum Presentation {
        
        /// This will render a regular full size card
        case regular
        
        /// This will render a mini card that can have an optional action
        case mini
    }
    
    /// The interaction of the user with the card itself
    public enum Interaction {
        
        /// The background is tappable
        case tappable(() -> Void)
        
        /// No interaction
        case none
        
        var isTappable: Bool {
            switch self {
            case .tappable:
                return true
            case .none:
                return false
            }
        }
    }
    
    // MARK: - Properties
    
    public var priority: Priority {
        switch type {
        case .blockstackAirdropRegisteredMini:
            return .low
        default:
            return .high
        }
    }
    
    public let presentation: Presentation
    
    let type: AnnouncementType?
    let interaction: Interaction
    let contentAlignment: Alignment
    let background: Background
    let border: Border
    let image: Image
    let title: String?
    let description: String?
    let buttons: [ButtonViewModel]
    let didAppear: DidAppear?
    
    /// Returns `true` if the dismiss button should be hidden
    var isDismissButtonHidden: Bool {
        switch dismissState {
        case .undismissible:
            return true
        case .dismissible:
            return false
        }
    }
    
    /// The action associated with the announcement dismissal.
    /// Must be accessed ONLY if `dismissState` value is `.dismissible`
    var dismissAction: DismissState.Action! {
        switch dismissState {
        case .dismissible(let action):
            return action
        case .undismissible:
            recorder.error("dismiss action was accessed but not defined")
            return nil
        }
    }
        
    private let dismissState: DismissState
    private let recorder: ErrorRecording
    
    /// Upon receiving events triggers dismissal.
    /// This comes in handy when the user has performed an indirect
    /// action that should cause card dismissal.
    let dismissalRelay = PublishRelay<Void>()
    
    private var dismissal: Completable {
        return dismissalRelay
            .take(1)
            .ignoreElements()
            .observeOn(MainScheduler.instance)
    }
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(type: AnnouncementType? = nil,
                presentation: Presentation = .regular,
                interaction: Interaction = .none,
                contentAlignment: Alignment = .natural,
                background: Background = .white,
                border: Border = .bottomSeparator(.mediumBorder),
                image: Image,
                title: String? = nil,
                description: String? = nil,
                buttons: [ButtonViewModel] = [],
                recorder: ErrorRecording,
                dismissState: DismissState,
                didAppear: DidAppear? = nil) {
        self.type = type
        self.presentation = presentation
        self.interaction = interaction
        self.contentAlignment = contentAlignment
        self.background = background
        self.border = border
        self.image = image
        self.title = title
        self.description = description
        self.dismissState = dismissState
        self.buttons = buttons
        self.recorder = recorder
        self.didAppear = didAppear
        
        if let dismissAction = dismissAction {
            dismissal
                .subscribe(onCompleted: dismissAction)
                .disposed(by: disposeBag)
        }
    }
}

extension AnnouncementCardViewModel: Equatable {
    public static func == (lhs: AnnouncementCardViewModel, rhs: AnnouncementCardViewModel) -> Bool {
        return lhs.type == rhs.type
    }
}
