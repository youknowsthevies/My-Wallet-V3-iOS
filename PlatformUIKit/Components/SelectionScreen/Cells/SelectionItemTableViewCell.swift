//
//  SelectionItemTableViewCell.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 31/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

final class SelectionItemTableViewCell: UITableViewCell {
    
    // MARK: - Injected
    
    var presenter: SelectionItemViewPresenter! {
        didSet {
            disposeBag = DisposeBag()
            guard let presenter = presenter else { return }
            thumbImageView.set(presenter.image)
            titleLabel.content = presenter.title
            descriptionLabel.content = presenter.description
            
            if presenter.image.isEmpty {
                thumbImageViewWidthConstraint.constant = 0.5
            } else {
                thumbImageViewWidthConstraint.constant = 40
            }
            
            presenter.selectionImage
                .bind(to: selectionImageView.rx.content)
                .disposed(by: disposeBag)
            accessibility = presenter.accessibility
        }
    }
    
    // MARK: - UI Properties
    
    private let thumbImageView = UIImageView()
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let selectionImageView = UIImageView()

    private var thumbImageViewWidthConstraint: NSLayoutConstraint!
    
    // MARK: - Accessors
    
    private var disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }
    
    // MARK: - Setup
    
    private func setup() {
        contentView.addSubview(thumbImageView)
        contentView.addSubview(stackView)
        contentView.addSubview(selectionImageView)
        
        thumbImageView.layout(edge: .height, to: 40)
        thumbImageViewWidthConstraint = thumbImageView.layout(edge: .width, to: 40)
        thumbImageView.layoutToSuperview(.leading, offset: 24)
        thumbImageView.layoutToSuperview(.centerY)
        thumbImageView.layoutToSuperview(axis: .vertical, offset: 16, priority: .defaultHigh)
        
        stackView.layoutToSuperview(axis: .vertical, offset: 16)
        stackView.layout(edge: .leading, to: .trailing, of: thumbImageView, offset: 16)
        stackView.layout(edge: .trailing, to: .leading, of: selectionImageView, offset: -16)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 4
        
        stackView.insertArrangedSubview(titleLabel, at: 0)
        stackView.insertArrangedSubview(descriptionLabel, at: 1)
        titleLabel.verticalContentHuggingPriority = .required
        titleLabel.verticalContentCompressionResistancePriority = .required
        descriptionLabel.verticalContentHuggingPriority = .required
        descriptionLabel.verticalContentCompressionResistancePriority = .required
        
        selectionImageView.layout(size: .init(edge: 20))
        selectionImageView.layoutToSuperview(.trailing, offset: -16)
        selectionImageView.layoutToSuperview(.centerY)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        guard selected else { return }
        contentView.backgroundColor = .background
        UIView.animate(withDuration: 0.2, animations: {
            self.contentView.backgroundColor = .white
        }, completion: nil)
    }
}

