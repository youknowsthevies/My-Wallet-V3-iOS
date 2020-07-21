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
    
    public var presenter: AmountLabelViewPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let presenter = presenter else { return }
            
            presenter.output
                .map { $0.string }
                .drive(amountLabel.rx.attributedText)
                .disposed(by: disposeBag)
            
            presenter.output
                .map { $0.accessibility }
                .drive(amountLabel.rx.accessibility)
                .disposed(by: disposeBag)
        }
    }
    
    // MARK: - UI Properties
    
    private let amountLabel = UILabel()
    
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
        addSubview(amountLabel)
        amountLabel.fillSuperview()
        amountLabel.minimumScaleFactor = 0.35
        amountLabel.adjustsFontSizeToFitWidth = true
        amountLabel.textAlignment = .center
        amountLabel.baselineAdjustment = .alignCenters
        
        amountLabel.horizontalContentHuggingPriority = UILayoutPriority.penultimateHigh
        amountLabel.horizontalContentCompressionResistancePriority = UILayoutPriority.penultimateHigh
    }
}
