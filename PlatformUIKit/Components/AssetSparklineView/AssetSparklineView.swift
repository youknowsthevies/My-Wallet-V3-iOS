//
//  AssetSparklineView.swift
//  PlatformUIKit
//
//  Created by AlexM on 10/25/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa

public final class AssetSparklineView: UIView {
    
    // MARK: - Injected
    
    public var presenter: AssetSparklinePresenter! {
        didSet {
            if presenter != nil {
                calculate()
            }
        }
    }
    
    // MARK: - Private Properties
    
    private var path: Driver<UIBezierPath?> {
        pathRelay.asDriver()
    }
    
    private var lineColor: Driver<UIColor> {
        Driver.just(presenter.lineColor)
    }
    
    private var fillColor: Driver<UIColor> {
        Driver.just(.clear)
    }
    
    private var lineWidth: Driver<CGFloat> {
        Driver.just(attributes.lineWidth)
    }
    
    private let pathRelay: BehaviorRelay<UIBezierPath?> = BehaviorRelay(value: nil)
    private let shape: CAShapeLayer = CAShapeLayer()
    private var disposeBag = DisposeBag()
    
    private var attributes: SparklineAttributes {
        .init(size: frame.size)
    }

    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func calculate() {
        let calculator = SparklineCalculator(attributes: attributes)
        presenter.state
            .compactMap { state -> UIBezierPath? in
                switch state {
                case .valid(prices: let prices):
                    return calculator.sparkline(with: prices)
                case .empty, .invalid, .loading:
                    return nil
                }
            }
            .bind(to: pathRelay)
            .disposed(by: disposeBag)
        
        lineWidth
            .drive(shape.rx.lineWidth)
            .disposed(by: disposeBag)
        
        lineColor
            .drive(shape.rx.strokeColor)
            .disposed(by: disposeBag)
        
        fillColor
            .drive(shape.rx.fillColor)
            .disposed(by: disposeBag)
    }
    
    private func setup() {
        if layer.sublayers == nil {
            shape.bounds = frame
            shape.position = center
            layer.addSublayer(shape)
        }
        
        path.drive(shape.rx.path)
            .disposed(by: disposeBag)
    }
}
