//
//  NoticeView.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 28/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

public final class NoticeView: UIView {

    // MARK: - IBOutlet Properties
    
    private let imageView = UIImageView()
    private let label = UILabel()
    
    private var topAlignmentConstraint: NSLayoutConstraint!
    private var centerAlignmentConstraint: NSLayoutConstraint!
    
    // MARK: - Injected
    
    public var viewModel: NoticeViewModel! {
        didSet {
            guard let viewModel = viewModel else { return }
            imageView.set(viewModel.imageViewContent)
            label.content = viewModel.labelContent
            switch viewModel.verticalAlignment {
            case .center:
                topAlignmentConstraint.priority = .defaultLow
                centerAlignmentConstraint.priority = .penultimateHigh
            case .top:
                topAlignmentConstraint.priority = .penultimateHigh
                centerAlignmentConstraint.priority = .defaultLow
            }
            layoutIfNeeded()
        }
    }
    
    // MARK: - Setup
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
        
    private func setup() {
        imageView.contentMode = .scaleAspectFit
        label.font = .main(.medium, 12)
        label.textColor = .descriptionText
        label.numberOfLines = 0
        
        addSubview(imageView)
        addSubview(label)
        
        imageView.layoutToSuperview(.leading)
        imageView.layout(size: .init(edge: 20))
        
        topAlignmentConstraint = imageView.layout(to: .top, of: label, priority: .penultimateHigh)
        centerAlignmentConstraint = imageView.layout(to: .centerY, of: label, priority: .defaultLow)

        label.layout(edge: .leading, to: .trailing, of: imageView, offset: 18)
        label.layoutToSuperview(.top, .bottom, .trailing)
    }
}
