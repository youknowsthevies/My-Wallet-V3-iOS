import Combine

extension Publisher {

    func replaceOutput<T>(_ value: T) -> Publishers.Map<Self, T> {
        map { _ in value }
    }
}

extension Collection where Element: Publisher {

    func merge() -> Publishers.MergeMany<Element> {
        Publishers.MergeMany(self)
    }
}
