// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct WithGeometry<T, Base: View, Content: View>: View {

    enum Update {
        case onAppear
        case onChange
    }

    var base: Base
    var transform: (GeometryProxy) -> T
    var content: (Base, T) -> Content
    var update: Update

    init(
        _ base: Base,
        geometry transform: @escaping (GeometryProxy) -> T,
        update: Update = .onAppear,
        @ViewBuilder content: @escaping (Base, T) -> Content
    ) {
        self.base = base
        self.transform = transform
        self.content = content
    }

    @State private var value: T? = nil

    var body: some View {
        _content
            .background(
                GeometryReader { geometry in
                    switch update {
                    case .onAppear:
                        Color.clear.onAppear { value = transform(geometry) }
                    case .onChange:
                        Color.clear.modifier(SizeModifier())
                            .onPreferenceChange(SizePreferenceKey.self) { self.contentSize = $0 }
                    }
                }
            )
    }

    @ViewBuilder
    var _content: some View {
        if let value = value {
            content(base, value)
        } else {
            base
        }
    }
}

extension View {

    public func withGeometry<T, V: View>(
        _ transform: @escaping (GeometryProxy) -> T,
        @ViewBuilder content: @escaping (Self, T) -> V
    ) -> some View {
        WithGeometry(self, geometry: transform, content: content)
    }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct SizeModifier: ViewModifier {
    private var sizeView: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: SizePreferenceKey.self, value: geometry.size)
        }
    }

    func body(content: Content) -> some View {
        content.background(sizeView)
    }
}
