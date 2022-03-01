// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Combine
import CombineSchedulers
import ComposableArchitecture
import FeatureCoinDomain
import Foundation
import Localization
import MoneyKit
import NetworkError
import SwiftUI
import ToolKit

public struct CoinViewGraphState: Equatable {

    @BindableState var selected: Int?
    var interval: HistoricalPrice.Series = ._15_minutes

    var result: Result<GraphData, NetworkError>?
    var isFetching: Bool = false

    var tolerance: Int = 2
    var density: Int = 250
    var date = Date()
}

public enum CoinViewGraphAction: BindableAction {
    case binding(_ action: BindingAction<CoinViewGraphState>)
    case request(HistoricalPrice.Series, force: Bool = false)
    case fetched(Result<GraphData, NetworkError>)
}

public let coinViewGraphReducer = Reducer<
    CoinViewGraphState,
    CoinViewGraphAction,
    CoinViewEnvironment
> { state, action, environment in
    struct FetchID: Hashable {}
    switch action {
    case .request(let interval, let force):
        guard force || interval != state.interval else {
            return .none
        }
        state.isFetching = true
        state.interval = interval
        return .merge(
            .cancel(id: FetchID()),
            environment.historicalPriceService.fetch(
                series: interval,
                relativeTo: state.date
            )
            .catchToEffect()
            .map(CoinViewGraphAction.fetched)
            .cancellable(id: FetchID())
        )
    case .fetched(let data):
        state.result = data
        state.isFetching = false
        return .none
    case .binding:
        return .none
    }
}
.binding()

public struct CoinViewGraph: View {

    typealias Localization = LocalizationConstants.Coin.Graph

    let store: Store<CoinViewGraphState, CoinViewGraphAction>

    public init(store: Store<CoinViewGraphState, CoinViewGraphAction>) {
        self.store = store
    }

    @State private var animation = false

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                switch viewStore.result {
                case .none:
                    ProgressView()
                        .progressViewStyle(.linear)
                        .onAppear {
                            viewStore.send(.request(.week))
                        }
                        .padding()
                case .failure:
                    AlertCard(
                        title: Localization.Error.title,
                        message: Localization.Error.description
                    )
                    SmallPrimaryButton(title: Localization.Error.retry, isLoading: viewStore.isFetching) {
                        viewStore.send(.request(viewStore.interval, force: true))
                    }
                case .success(let value):
                    if value.series.isEmpty {
                        AlertCard(
                            title: Localization.Error.title,
                            message: Localization.Error.description
                        )
                    } else {
                        balance(
                            in: value,
                            series: viewStore.interval,
                            selected: viewStore.selected
                        )
                        LineGraph(
                            selection: viewStore.binding(\.$selected),
                            selectionTitle: { i, _ in
                                timestamp(value.series[i])
                            },
                            minimumTitle: amount(quote: value.quote),
                            maximumTitle: amount(quote: value.quote),
                            data: value.series.map(\.price),
                            tolerance: viewStore.tolerance,
                            density: viewStore.density
                        )
                        .opacity(viewStore.isFetching ? 0.5 : 1)
                        .overlay(
                            ZStack {
                                if animation {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                }
                            }
                            .onChange(of: viewStore.isFetching) { isFetching in
                                guard isFetching else {
                                    self.animation = false
                                    return
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    if viewStore.isFetching {
                                        self.animation = true
                                    }
                                }
                            }
                            .animation(.linear)
                        )
                        .typography(.caption2)
                        .foregroundColor(.semantic.title)
                        .animation(.easeInOut)
                        .onChange(of: viewStore.selected) { [old = viewStore.selected] new in
                            #if canImport(UIKit)
                            switch (new, old) {
                            case (.some, .some):
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            case _:
                                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            }
                            #endif
                        }
                    }
                }
                Spacer()
                PrimarySegmentedControl(
                    items: [
                        PrimarySegmentedControl.Item(title: Localization.TimePeriod.day, identifier: .day),
                        PrimarySegmentedControl.Item(title: Localization.TimePeriod.week, identifier: .week),
                        PrimarySegmentedControl.Item(title: Localization.TimePeriod.month, identifier: .month),
                        PrimarySegmentedControl.Item(title: Localization.TimePeriod.year, identifier: .year),
                        PrimarySegmentedControl.Item(title: Localization.TimePeriod.all, identifier: .all)
                    ],
                    selection: Binding(
                        get: { viewStore.interval },
                        set: { newValue in viewStore.send(.request(newValue)) }
                    )
                )
                .disabled(viewStore.isFetching)
            }
        }
        .frame(minHeight: 420.pt)
    }

    private func timestamp(_ index: GraphData.Index) -> Text {
        Text("\(Self.dateFormatter.string(from: index.timestamp))")
    }

    private func amount(quote: FiatCurrency) -> (_ index: Int, _ value: Double) -> Text {
        { _, value in Text(amount: value, currency: quote) }
    }

    private func balance(
        in value: GraphData,
        series: HistoricalPrice.Series,
        selected: Int?
    ) -> some View {

        func view(
            for index: GraphData.Index,
            relativeTo comparison: GraphData.Index
        ) -> ChartBalance {
            let percentage = Self.percentageFormatter.string(
                from: NSNumber(
                    value: abs(1 - (index.price / comparison.price))
                )
            )!
            return ChartBalance(
                title: selected == nil ? Localization.currentPrice : Localization.price,
                balance: String(
                    amount: selected == nil ? index.price : comparison.price,
                    currency: value.quote
                ),
                changeArrow: index.price.isNearlyEqual(to: comparison.price)
                    ? "→"
                    : index.price < comparison.price ? "↓" : "↑",
                changeAmount: String(
                    amount: abs(index.price - comparison.price),
                    currency: value.quote
                ),
                changePercentage: "(\(percentage))",
                changeColor: index.price.isNearlyEqual(to: comparison.price)
                    ? .semantic.primary
                    : index.price < comparison.price ? .semantic.error : .semantic.success,
                changeTime: Self.relativeDateFormatter.localizedString(
                    for: comparison.timestamp, relativeTo: index.timestamp
                )
            )
        }

        let current = value.series.last!
        if let selected = selected, value.series.indices.contains(selected) {
            return view(for: current, relativeTo: value.series[selected])
        } else {
            return view(for: current, relativeTo: value.series[0])
        }
    }

    private static let percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    private static let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.formattingContext = .standalone
        formatter.unitsStyle = .full
        return formatter
    }()
}

extension BinaryFloatingPoint {

    func isNearlyEqual(to other: Self, precision: Self = .init(0.01)) -> Bool {
        abs(self - other) <= precision
    }
}

struct CoinViewGraphPreviewProvider: PreviewProvider {
    static var previews: some View {
        CoinViewGraph(
            store: .init(
                initialState: .init(),
                reducer: coinViewGraphReducer,
                environment: .init(
                    kycStatusProvider: { .empty() },
                    accountsProvider: { .empty() },
                    historicalPriceService: .preview
                )
            )
        )
    }
}
