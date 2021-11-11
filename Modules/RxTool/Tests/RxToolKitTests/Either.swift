// Copyright © Blockchain Luxembourg S.A. All rights reserved.

enum Either<A, B> {
    case a(A), b(B)
}

extension Either: Equatable where A: Equatable, B: Equatable {}
extension Either: Hashable where A: Hashable, B: Hashable {}

extension Either {

    static func randomRoute(
        in a: [A],
        and b: [B],
        bias: Double = 0.5,
        length: ClosedRange<Int>
    ) -> [Self] {
        let lower = max(0, length.lowerBound)
        let upper = max(lower, length.upperBound)
        return (0..<Int.random(in: lower...upper)).compactMap { _ -> Self? in
            Double.random(in: 0...1) < bias
                ? a.randomElement().map(Self.a)
                : b.randomElement().map(Self.b)
        }
    }

    static func randomRoutes(
        count: Int,
        in a: [A],
        and b: [B],
        bias: Double = 0.5,
        length: ClosedRange<Int>
    ) -> [[Self]] {
        (0..<max(0, count)).map { _ in
            randomRoute(in: a, and: b, bias: bias, length: length)
        }
    }
}
