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
    private let stackView = UIStackView()
    
    private var topAlignmentConstraint: NSLayoutConstraint!
    private var centerAlignmentConstraint: NSLayoutConstraint!
    
    // MARK: - Injected
    
    public var viewModel: NoticeViewModel! {
        didSet {
            guard let viewModel = viewModel else { return }
            imageView.set(viewModel.imageViewContent)
            stackView.removeSubviews()
            
            viewModel.labelContents
                .map {
                    let label = UILabel()
                    label.content = $0
                    label.numberOfLines = 0
                    return label
                }
                .forEach {
                    stackView.addArrangedSubview($0)
                }
            
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
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.spacing = 4
        
        imageView.contentMode = .scaleAspectFit
        
        addSubview(imageView)
        addSubview(stackView)
        
        imageView.layoutToSuperview(.leading)
        imageView.layout(size: .init(edge: 20))
        
        topAlignmentConstraint = imageView.layout(to: .top, of: stackView, priority: .penultimateHigh)
        centerAlignmentConstraint = imageView.layout(to: .centerY, of: stackView, priority: .defaultLow)

        stackView.layout(edge: .leading, to: .trailing, of: imageView, offset: 18)
        stackView.layoutToSuperview(axis: .vertical, priority: .penultimateHigh)
        stackView.layoutToSuperview(.trailing)
    }
}
