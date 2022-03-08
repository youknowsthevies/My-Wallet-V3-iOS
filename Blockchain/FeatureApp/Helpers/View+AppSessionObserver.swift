import BlockchainNamespace
import SwiftUI

protocol AppSessionObserver: ViewModifier {
    var id: ObjectIdentifier { get }
}

extension AppSessionObserver {
    var id: ObjectIdentifier { ObjectIdentifier(Self.self) }
}

extension View {

    func observer<A: AppSessionObserver>(
        _ observer: A
    ) -> some View {
        self.observer([observer])
    }

    func observer<C: RandomAccessCollection>(
        _ collection: C
    ) -> some View where C.Element: AppSessionObserver {
        background(ForEach(collection, id: \.id, content: Color.clear.modifier))
    }
}
