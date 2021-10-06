# ComposableNavigation

A small DSL over swift-composable-architecture that provides a navigation effect. Routes from a page are described through an enum that provides the destination in the context of the composable `Store<State, Action>`  

**Directly send an action to ViewStore**
```swift
viewStore.send(.navigate(to: .approve))
```

**Return navigation as an effect**
```swift
case let .select(institution):
    ...
    return .navigate(to: .approve)
```

**Define a NavigationRoute**
```swift
public enum InstitutionListRoute: CaseIterable, NavigationRoute {

    case approve

    @ViewBuilder
    public func destination(in store: Store<InstitutionListState, InstitutionListAction>) -> some View {
        switch self {
        case .approve:
            IfLetStore(
                store.scope(state: \.selection, action: InstitutionListAction.approve),
                then: ApproveView.init(store:)
            )
        }
    }
}

```

## How-to

1. Conform your existing `State` and `Action` to `NavigationState` and `NavigationAction` as well as implementing the protocol requirements

```swift
struct ExampleState: Equatable, NavigationState {
    var route: RouteIntent<ExampleRoute>?
    ...
```

```swift
enum ExampleAction: NavigationAction {
    case route(RouteIntent<ExampleRoute>?)
    ...
```

2. Create a new type which conforms to `NavigationRoute`, you will also be required to conform to `CaseIterable` or implement `allRoutes`

```swift
enum ExampleRoute: NavigationRoute {
    case a
    
    @ViewBuilder
    func destination(in store: Store<ExampleState, ExampleAction>) -> some View {
        ...
    }
}
```

3. Associate your route with your SwiftUI view, this can be placed anywhere in the view - typically found alongside other navigation modifiers like `navigationTitle`

```swift
VStack {
...
}
.navigationTitle(name)
.navigationRoute(in: store)
```

4. Trigger navigation via an Effect or Action

```swift
let exampleReducer = Reducer<ExampleState, ExampleAction, Void> { state, action, _ in
    switch action {
    case exampleAction:
        return .navigate(to: .a)
    case .route(let o):
        state.route = o
        return .none
    }
}
```

```swift
viewStore.send(.enter(into: .a))
```
