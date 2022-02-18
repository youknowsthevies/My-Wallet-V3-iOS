// Copyright © Blockchain Luxembourg S.A. All rights reserved.
// swiftlint:disable all

import BlockchainComponentLibrary
import Combine
import SwiftUI

struct LineGraphExamples: View {

    class Object: ObservableObject {

        @Published var data: GraphData?
        var bag: Set<AnyCancellable> = []

        func fetch(_ series: HistoricalBTCPrice.Series) {
            HistoricalBTCPrice()
                .data(series)
                .ignoreFailure(setFailureType: Never.self)
                .receive(on: DispatchQueue.main)
                .assign(to: &$data)
        }
    }

    @State var selectedIndex: Int?
    @State var tolerance: Double = 2
    @State var density: Double = 300

    @State var interval: HistoricalBTCPrice.Series = .week

    @ObservedObject var object: Object = .init()

    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading) {
            if let data = object.data {
                Group {
                    Text("BTC Price")
                        .foregroundColor(.semantic.title)
                        .typography(.caption2)
                    Group {
                        if let index = selectedIndex {
                            Text("\(format(data.series[index].price))")
                        } else if let latest = data.series.last {
                            Text("\(format(latest.price))")
                        }
                    }
                    .typography(.title1)
                    .foregroundColor(.semantic.title)
                }
                .padding([.leading, .trailing], 24.pt)
                LineGraph(
                    selection: $selectedIndex,
                    selectionTitle: { i, _ in
                        Text("\(dateFormatter.string(from: data.series[i].timestamp))")
                            .typography(.caption2)
                            .foregroundColor(.semantic.title)
                    },
                    minimumTitle: { _, d in
                        Text("\(format(d))")
                            .typography(.caption2)
                            .foregroundColor(.semantic.title)
                    },
                    maximumTitle: { _, d in
                        Text("\(format(d))")
                            .typography(.caption2)
                            .foregroundColor(.semantic.title)
                    },
                    data: data.series.map(\.price),
                    tolerance: Int(tolerance),
                    density: Int(density)
                )
                .animation(.easeInOut)
            } else {
                Spacer()
                ProgressView()
                    .progressViewStyle(.circular)
                    .onAppear {
                        object.fetch(interval)
                    }
                Spacer()
            }
            HStack {
                Spacer()
                PrimarySegmentedControl(
                    items: [
                        PrimarySegmentedControl.Item(title: "1D", identifier: .day),
                        PrimarySegmentedControl.Item(title: "1W", identifier: .week),
                        PrimarySegmentedControl.Item(title: "1M", identifier: .month),
                        PrimarySegmentedControl.Item(title: "1Y", identifier: .year),
                        PrimarySegmentedControl.Item(title: "All", identifier: .all)
                    ],
                    selection: $interval
                )
                .onChange(of: interval) { newValue in
                    object.fetch(newValue)
                }
                Spacer()
            }
            Group {
                VStack {
                    Text("Tolerance = \(Int(tolerance))")
                    Slider(value: $tolerance, in: 0...50, step: 1)
                        .padding()
                }
                VStack {
                    Text("Density = \(Int(density))")
                    Slider(value: $density, in: 0...1000, step: 25)
                        .padding()
                }
            }
            .typography(.body2)
            .padding([.leading, .trailing])
        }
        .background(Color.semantic.background)
    }

    func format(_ value: Double) -> String {
        numberFormatter.string(from: .init(value: value)) ?? "NaN"
    }
}

struct LineGraphExamples_Previews: PreviewProvider {
    static var previews: some View {
        LineGraphExamples()
    }
}

struct GraphData {

    struct Index: Decodable {
        let price: Double
        let timestamp: Date
    }

    let series: [Index]

    let base: String
    let quote: String
}

struct HistoricalBTCPrice {
    let code: String = "BTC"
    let fiat: String = "USD"
}

extension HistoricalBTCPrice.Interval {
    static let hour = Self(value: 1, component: .hour)
    static let day = Self(value: 1, component: .day)
    static let weekdays = Self(value: 5, component: .weekday)
    static let week = Self(value: 1, component: .weekOfMonth)
    static let month = Self(value: 1, component: .month)
    static let year = Self(value: 1, component: .year)
    static let all = Self(value: 20, component: .year)
}

extension HistoricalBTCPrice.Series {
    static let day = Self(window: .day, density: .hour)
    static let week = Self(window: .week, density: .hour)
    static let month = Self(window: .month, density: .hour)
    static let year = Self(window: .year, density: .day)
    static let all = Self(window: .all, density: .weekdays)
}

extension HistoricalBTCPrice {

    struct Series: Hashable {
        let window: Interval
        let density: Interval
    }

    struct Interval: Hashable {
        let value: Int
        let component: Calendar.Component
    }

    func data(_ series: Series) -> AnyPublisher<GraphData, Error> {

        let calendar = Calendar.current

        let now = Date()

        let startingAt = calendar.date(
            byAdding: series.window.component,
            value: -series.window.value,
            to: now
        )!

        let every = calendar.date(
            byAdding: series.density.component,
            value: series.density.value,
            to: now
        )!

        var components: URLComponents = .init(
            string: "https://api.blockchain.info/price/index-series"
        )!

        components.queryItems = [
            URLQueryItem(name: "base", value: code),
            URLQueryItem(name: "quote", value: fiat),
            URLQueryItem(name: "start", value: Int(startingAt.timeIntervalSince1970).description),
            URLQueryItem(name: "scale", value: Int(every.timeIntervalSince(now)).description)
        ]

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return URLSession.shared.dataTaskPublisher(for: components.url!)
            .map(\.data)
            .decode(type: [GraphData.Index].self, decoder: decoder)
            .map { series in
                GraphData(
                    series: series,
                    base: code,
                    quote: fiat
                )
            }
            .eraseToAnyPublisher()
    }
}

extension Publisher {

    public func ignoreFailure<NewFailure: Error>(
        setFailureType failureType: NewFailure.Type = NewFailure.self
    ) -> AnyPublisher<Output, NewFailure> {
        `catch` { _ in Empty() }
            .setFailureType(to: failureType)
            .eraseToAnyPublisher()
    }
}

extension CustomStringConvertible {

    func peek() -> Self {
        print(description)
        return self
    }
}

extension Publisher where Failure == Never {

    func assign(to published: inout Published<Output?>.Publisher) {
        map(Output?.init).assign(to: &published)
    }
}
