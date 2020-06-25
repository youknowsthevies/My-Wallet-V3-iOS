//
//  AssetLineChartUserInteractor.swift
//  Blockchain
//
//  Created by AlexM on 11/21/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Charts
import Foundation
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class AssetLineChartUserInteractor: AssetLineChartUserInteracting, ChartViewDelegate {
    
    var state: Observable<AssetLineChartInteractionState> {
        stateRelay
            .observeOn(MainScheduler.instance)
            .asObservable()
    }
    
    private let disposeBag = DisposeBag()
    private let stateRelay = BehaviorRelay<AssetLineChartInteractionState>(value: .deselected)
    private let deselectedTrigger = PublishRelay<Void>()
    private var selectedIndex: Observable<Int> {
        selectedIndexRelay.asObservable()
    }
    private var selectedIndexRelay = PublishRelay<Int>()
    
    init(chartView: LineChartView) {
        chartView.delegate = self
        setup()
    }
    
    private func setup() {
        deselectedTrigger
            .map { .deselected }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
        
        selectedIndexRelay
            .map { .selected($0) }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
    
    // MARK: - ChartViewDelegate
    
    func chartViewDidEndPanning(_ chartView: ChartViewBase) {
        chartView.highlightValue(nil)
        deselectedTrigger.accept(())
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        deselectedTrigger.accept(())
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let index = entry.data as? NSNumber else { return }
        selectedIndexRelay.accept(index.intValue)
    }
}
