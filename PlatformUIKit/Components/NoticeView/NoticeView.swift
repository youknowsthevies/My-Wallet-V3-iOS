//
//  NoticeView.swift
//  Blockchain
//
//  Created by Daniel Huri on 28/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

public final class NoticeView: UIView {

    // MARK: - IBOutlet Properties
    
    private let imageView = UIImageView()
    private let label = UILabel()
    
    // MARK: - Injected
    
    public var viewModel: NoticeViewModel! {
        didSet {
            guard let viewModel = viewModel else { return }
            imageView.image = UIImage(named: viewModel.image)
            label.content = viewModel.labelContent
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
        label.font = .mainMedium(12)
        label.textColor = .descriptionText
        label.numberOfLines = 0
        
        addSubview(imageView)
        addSubview(label)
        
        imageView.layoutToSuperview(.leading)
        imageView.layout(size: .init(edge: 20))
        imageView.layout(to: .top, of: label)
        
        label.layout(edge: .leading, to: .trailing, of: imageView, offset: 18)
        label.layoutToSuperview(.top, .bottom, .trailing)
    }
}
