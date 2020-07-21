//
//  AnnouncementCardView.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 21/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxRelay
import RxSwift

public protocol AnnouncementCardViewConforming: UIView {}

public final class AnnouncementCardView: UIView, AnnouncementCardViewConforming {
    
    // MARK: - UI Properties
    
    @IBOutlet private var backgroundImageView: UIImageView!
    @IBOutlet private var thumbImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var dismissButton: UIButton!
    @IBOutlet private var buttonsStackView: UIStackView!
    @IBOutlet private var buttonPlaceholderSeparatorView: UIView!
    @IBOutlet private var badgeImageView: BadgeImageView!
    @IBOutlet private var badgeView: BadgeView!
    
    @IBOutlet private var bottomSeparatorView: UIView!
    
    @IBOutlet private var titleToThumbnailImageView: NSLayoutConstraint!
    @IBOutlet private var titleToBadgeImageView: NSLayoutConstraint!
    @IBOutlet private var imageViewLeadingToSuperviewConstraint: NSLayoutConstraint!
    @IBOutlet private var imageViewCenterInSuperviewConstraint: NSLayoutConstraint!
    @IBOutlet private var stackViewToBottomConstraint: NSLayoutConstraint!
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Injected
    
    private let viewModel: AnnouncementCardViewModel
    
    // MARK: - Setup
    
    public init(using viewModel: AnnouncementCardViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) is not implemented")
    }
    
    private func setup() {
        fromNib()
        clipsToBounds = true
        backgroundColor = viewModel.background.color
        backgroundImageView.image = viewModel.background.image

        thumbImageView.image = viewModel.image.uiImage
        thumbImageView.tintColor = viewModel.image.tintColor
        thumbImageView.layout(size: viewModel.image.size)
        if let viewModel = viewModel.badgeImage.viewModel {
            badgeImageView.viewModel = viewModel
        }
        badgeImageView.layout(size: viewModel.badgeImage.size)
        titleLabel.text = viewModel.title
        titleLabel.textColor = .titleText
        descriptionLabel.text = viewModel.description
        descriptionLabel.textColor = .descriptionText
        
        switch viewModel.border {
        case .bottomSeparator(let color):
            bottomSeparatorView.isHidden = false
            bottomSeparatorView.backgroundColor = color
        case .roundCorners(let radius):
            bottomSeparatorView.isHidden = true
            layer.cornerRadius = radius
        case .none:
            bottomSeparatorView.isHidden = true
        }
                
        setupButtons()
        fixPositions()
        setupAccessibility()
        viewModel.didAppear?()
    }
    
    private func setupAccessibility() {
        typealias Identifier = Accessibility.Identifier.Dashboard.Announcement
        titleLabel.accessibility = .init(id: .value(Identifier.titleLabel))
        descriptionLabel.accessibility = .init(id: .value(Identifier.descriptionLabel))
        thumbImageView.accessibility = .init(id: .value(Identifier.imageView))
        dismissButton.accessibility = .init(id: .value(Identifier.dismissButton))
    }
    
    private func setupButtons() {
        dismissButton.isHidden = viewModel.isDismissButtonHidden
        dismissButton.rx.tap
            .bindAndCatch(to: viewModel.dismissalRelay)
            .disposed(by: disposeBag)
        
        for buttonViewModel in viewModel.buttons {
            setupButton(for: buttonViewModel)
        }
    }
    
    private func setupButton(for viewModel: ButtonViewModel) {
        let button = ButtonView()
        button.viewModel = viewModel
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 50)
            ])
        buttonsStackView.addArrangedSubview(button)
    }
    
    private func fixPositions() {
        if viewModel.title == nil {
            titleToThumbnailImageView.constant = 0
            titleToBadgeImageView.constant = 0
        }
        
        if !viewModel.image.isVisible {
            thumbImageView.removeFromSuperview()
        }
        
        if !viewModel.badgeImage.isVisible {
            badgeImageView.removeFromSuperview()
        }
        
        if viewModel.buttons.isEmpty {
            stackViewToBottomConstraint.constant = 0
        } else { // Remove placeholder view since there are actual buttons
            buttonPlaceholderSeparatorView.removeFromSuperview()
        }
        
        titleToBadgeImageView.constant = viewModel.badgeImage.verticalPadding
        
        switch viewModel.contentAlignment {
        case .center:
            titleLabel.textAlignment = .center
            descriptionLabel.textAlignment = .center
            imageViewLeadingToSuperviewConstraint.priority = .defaultLow
            imageViewCenterInSuperviewConstraint.priority = .penultimateHigh
        case .natural:
            titleLabel.textAlignment = .natural
            descriptionLabel.textAlignment = .natural
            imageViewLeadingToSuperviewConstraint.priority = .penultimateHigh
            imageViewCenterInSuperviewConstraint.priority = .defaultLow
        }
    }
}
