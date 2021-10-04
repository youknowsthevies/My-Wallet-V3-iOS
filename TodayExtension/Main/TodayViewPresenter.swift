// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxDataSources
import RxRelay
import RxSwift

protocol TodayViewPresenting {

    var sectionObservable: Observable<[TodayExtensionSectionViewModel]> { get }
    var numberOfSections: Int { get }

    func refresh()
    func viewModel(for section: Int) -> TodayExtensionSectionHeaderViewModel
}

final class TodayViewPresenter: TodayViewPresenting {

    // MARK: - Public Properties

    var sectionObservable: Observable<[TodayExtensionSectionViewModel]> {
        _ = setup
        return Observable
            .combineLatest(
                portfolioCellRelay,
                assetCellsRelay
            )
            .map { values -> [TodayExtensionSectionViewModel] in
                var result: [TodayExtensionSectionViewModel] = []
                if let portfolio = values.0 {
                    result.append(.init(sectionType: .balance, items: [portfolio]))
                }
                result.append(.init(sectionType: .assetPrices, items: values.1))
                return result
            }
    }

    var numberOfSections: Int {
        interactor.isBalanceSyncingEnabled ? 2 : 1
    }

    // MARK: - Setup

    private lazy var setup: Void = {
        interactor
            .assetInteractors
            .map { items in items.map(\.cellType) }
            .map { cellTypes in cellTypes.map { TodayExtensionCellViewModel(cellType: $0) } }
            .bindAndCatch(to: assetCellsRelay)
            .disposed(by: disposeBag)

        interactor
            .portfolioInteractor
            .compactMap { $0 }
            .map(\.cellType)
            .map { TodayExtensionCellViewModel(cellType: $0) }
            .bindAndCatch(to: portfolioCellRelay)
            .disposed(by: disposeBag)
    }()

    // MARK: - Private Properties

    private var portfolioCell: Observable<TodayExtensionCellViewModel?> {
        portfolioCellRelay.asObservable()
    }

    private var assetCells: Observable<[TodayExtensionCellViewModel]> {
        assetCellsRelay.asObservable()
    }

    private let assetCellsRelay = BehaviorRelay<[TodayExtensionCellViewModel]>(value: [])
    private let portfolioCellRelay = BehaviorRelay<TodayExtensionCellViewModel?>(value: nil)
    private let interactor: TodayViewInteracting
    private let disposeBag = DisposeBag()

    // MARK: - Init

    init(interactor: TodayViewInteracting) {
        self.interactor = interactor
    }

    /// Should be called each time the dashboard view shows
    /// to trigger dashboard re-render
    func refresh() {
        interactor.refresh()
    }

    func viewModel(for section: Int) -> TodayExtensionSectionHeaderViewModel {
        switch section {
        case 0:
            return interactor.isBalanceSyncingEnabled ? .walletBalance : .prices
        case 1:
            return .prices
        default:
            fatalError("Unexpected section")
        }
    }
}
