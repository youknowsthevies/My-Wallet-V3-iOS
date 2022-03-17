// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension View {

    /// Display a bottom sheet over the current content
    /// - Parameters:
    ///   - item: An optional binding which determines what content should be shown
    ///   - content: The contents of the sheet
    /// - Returns: ZStack containing `self` overlayed with the bottom sheet view
    @ViewBuilder
    public func bottomSheet<Item, Content>(
        item: Binding<Item?>,
        @ViewBuilder content: (Item) -> Content
    ) -> some View where Content: View {
        bottomSheet(
            isPresented: Binding(
                get: { item.transaction(item.transaction).wrappedValue != nil },
                set: { newValue in
                    if !newValue {
                        item.transaction(item.transaction).wrappedValue = nil
                    }
                }
            ),
            content: {
                if let item = item.transaction(item.transaction).wrappedValue {
                    content(item)
                }
            }
        )
    }

    /// Display a bottom sheet over the current content
    /// - Parameters:
    ///   - isPresented: A binding which determines when the content should be shown
    ///   - content: The contents of the sheet
    /// - Returns: ZStack containing `self` overlayed with the bottom sheet view
    public func bottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        modifier(BottomSheetModifier(isPresented: isPresented, sheetContent: content()))
    }
}

/// A small sheet used to present content from a drawer.
/// The content presented will be dismissed via the user swiping down, using the handle,
/// tapping the handle or by tapping the faded area behind the presented sheet.
///
/// # Figma
/// [Sheet](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=209%3A10112)
struct BottomSheetView<Content: View>: View {

    let cornerRadius: CGFloat = 24
    var content: Content

    var body: some View {
        VStack {
            Capsule()
                .fill(Color.semantic.dark)
                .frame(width: 32.pt, height: 4.pt)
                .foregroundColor(.semantic.muted)
            content
        }
        .padding(8.pt)
        .padding(.bottom, 20.pt)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .foregroundColor(.semantic.background)
        )
        .offset(y: cornerRadius)
    }
}

extension BottomSheetView {

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
}

struct BottomSheetModifier<SheetContent: View>: ViewModifier {

    @Binding var isPresented: Bool

    @GestureState(
        resetTransaction: Transaction(animation: .interactiveSpring())
    ) var translation: CGSize = .zero

    let sheetContent: SheetContent

    @State private var inserted = false

    private func yTranslation(in proxy: GeometryProxy) -> CGFloat {
        if isPresented {
            return inserted ? proxy.size.height : max(translation.height, -10)
        } else {
            return proxy.size.height
        }
    }

    func body(content: Content) -> some View {
        content.overlay(
            Group {
                GeometryReader { proxy in
                    ZStack(alignment: .bottom) {
                        if isPresented {
                            Color.palette.overlay600
                                .onAppear { inserted = true }
                                .onDisappear { inserted = false }
                                .onTapGesture { isPresented = false }
                                .transition(.opacity)
                                .ignoresSafeArea()
                            BottomSheetView(content: sheetContent)
                                .zIndex(1)
                                .onChange(of: inserted) { newValue in
                                    guard newValue else { return }
                                    DispatchQueue.main.async {
                                        withAnimation(.spring()) { inserted = false }
                                    }
                                }
                                .transition(.move(edge: .bottom))
                                .offset(y: yTranslation(in: proxy))
                                .offset(y: 32.pt)
                        }
                    }
                    .highPriorityGesture(
                        DragGesture()
                            .updating($translation) { value, state, _ in
                                state = value.translation
                            }
                            .onEnded { value in
                                let endLocation = value.predictedEndLocation
                                let frame = proxy.frame(in: .global)
                                if endLocation.y > frame.maxY - 60 {
                                    isPresented = false
                                }
                            }
                    )
                }
            }
        )
    }
}

// swiftlint:disable type_name
struct BottomSheetView_PreviewContentView: View {
    @State var isPresented = false
    var body: some View {
        PrimaryButton(title: "Tap me") {
            withAnimation(.spring()) {
                isPresented = true
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .bottomSheet(
            isPresented: $isPresented.animation(.spring())
        ) {
            VStack {
                ForEach(1...5, id: \.self) { i in
                    PrimaryRow(
                        title: "Title",
                        subtitle: "Description",
                        leading: {
                            Icon.allIcons
                                .randomElement()!
                                .circle()
                                .accentColor(.semantic.primary)
                                .frame(maxHeight: 24.pt)
                        },
                        action: {}
                    )
                    .frame(maxHeight: 10.vh)
                    if i != 5 {
                        PrimaryDivider()
                    }
                }
            }
            .padding(.bottom, 50)
        }
    }
}

struct BottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BottomSheetView_PreviewContentView()
            BottomSheetView_PreviewContentView(isPresented: true)
        }
    }
}
