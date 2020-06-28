//
//  AmountLabelView.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 23/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit

public final class AmountLabelView: UIView {

    // MARK: - Exposed Properties
    
    public var viewModel: AmountLabelViewModel! {
        didSet {
            disposeBag = DisposeBag()
            guard let viewModel = viewModel else { return }
            
            viewModel.currencyCodeLabelContent
                .bindAndCatch(to: currencyCodeLabel.rx.content)
                .disposed(by: disposeBag)
            
            viewModel.amount
                .map { $0.amount }
                .bindAndCatch(to: amountLabel.rx.attributedText)
                .disposed(by: disposeBag)
            
            viewModel.amount
                .map { $0.accessibility }
                .bindAndCatch(to: amountLabel.rx.accessibility)
                .disposed(by: disposeBag)
            
            viewModel.stateImageContent
                .bindAndCatch(to: stateImageView.rx.content)
                .disposed(by: disposeBag)
        }
    }
    
    // MARK: - UI Properties
    
    private let currencyCodeLabel = UILabel()
    private let amountLabel = UILabel()
    private let stateImageView = UIImageView()
    
    // MARK: - Accessors
    
    private var disposeBag = DisposeBag()
    
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
        addSubview(currencyCodeLabel)
        addSubview(amountLabel)
        addSubview(stateImageView)
        
        currencyCodeLabel.layoutToSuperview(.leading)
        currencyCodeLabel.layoutToSuperview(axis: .vertical)
        currencyCodeLabel.maximizeResistanceAndHuggingPriorities()
        
        amountLabel.minimumScaleFactor = 0.4
        amountLabel.adjustsFontSizeToFitWidth = true
        amountLabel.textAlignment = .left
        amountLabel.baselineAdjustment = .alignCenters
        
        amountLabel.layoutToSuperview(.centerY)
        amountLabel.layout(edge: .leading, to: .trailing, of: currencyCodeLabel, offset: 8)
        amountLabel.layout(edge: .trailing, to: .leading, of: stateImageView, offset: -32)
        
        stateImageView.layoutToSuperview(.centerY)
        stateImageView.layoutToSuperview(.trailing)
        stateImageView.maximizeResistanceAndHuggingPriorities()
    }
}
