// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension View {

    /// Display a bottom sheet over the current content
    /// - Parameters:
    ///   - isPresented: A binding which determines when the content should be shown
    ///   - maximumHeight: The maximum height the sheet can reach, defaults to 70% of the viewport height
    ///   - content: The contents of the sheet
    /// - Returns: ZStack containing `self` overlayed with the bottom sheet view
    @ViewBuilder
    public func bottomSheet<Content>(
        isPresented: Binding<Bool>,
        maximumHeight: Length = 70.vh,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content: View {
        ZStack {
            self
            let bottomSheetView = BottomSheetView(
                isPresented: isPresented,
                maximumHeight: maximumHeight,
                content: content
            )
            Color.black
                .opacity(isPresented.wrappedValue ? 0.4 : 0)
                .frame(width: .infinity, height: .infinity)
                .ignoresSafeArea()
                .animation(.linear)
                .onTapGesture {
                    bottomSheetView.isPresented = false
                }
            bottomSheetView
                .ignoresSafeArea(.container, edges: .bottom)
        }
    }
}

/// A small sheet used to present content from a drawer.
/// The content presented will be dismissed via the user swiping down, using the handle,
/// tapping the handle or by tapping the faded area behind the presented sheet.
///
/// # Figma
/// [Sheet](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=209%3A10112)
public struct BottomSheetView<Content: View>: View {

    @Binding var isPresented: Bool

    let maximumHeight: Length
    let content: () -> Content

    @GestureState private var translation: CGFloat = 0

    public init(
        isPresented: Binding<Bool>,
        maximumHeight: Length,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.maximumHeight = maximumHeight
        self.content = content
        _isPresented = isPresented
    }

    public var body: some View {
        GeometryReader { geometry in
            let maximumHeight = maximumHeight.in(geometry)
            VStack(spacing: 0) {
                indicator
                    .padding()
                content()
            }
            .padding(.bottom, 20.pt)
            .frame(
                width: geometry.size.width,
                height: maximumHeight,
                alignment: .top
            )
            .background(Color.semantic.background)
            .cornerRadius(16)
            .frame(height: geometry.size.height, alignment: .bottom)
            .offset(y: max((isPresented ? 0 : maximumHeight) + translation, 0))
            .animation(.interactiveSpring())
            .gesture(
                DragGesture()
                    .updating($translation) { value, state, _ in
                        state = value.translation.height
                    }
                    .onEnded { value in
                        guard abs(value.translation.height) > maximumHeight / 4 else { return }
                        isPresented = value.translation.height < 0
                    }
            )
        }
    }

    private var indicator: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.semantic.medium)
            .frame(width: 32.pt, height: 4.pt)
            .onTapGesture {
                withAnimation(.linear) {
                    isPresented.toggle()
                }
            }
    }
}

struct BottomSheetView_Previews: PreviewProvider {

    static var previews: some View {
        Color.gray
            .overlay(
                BottomSheetView(
                    isPresented: Binding(get: { true }, set: { _ in }),
                    maximumHeight: 70.vh
                ) {
                    ForEach(0..<10) { i in
                        DefaultRow(title: "\(i)", accessoryView: { Icon.chevronRight })
                            .accentColor(.semantic.muted)
                        if i != 9 {
                            Divider()
                        }
                    }
                }
            )
            .ignoresSafeArea()
    }
}
