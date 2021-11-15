# Session

A lightweight flat key-value data structure for storing application state. 
The type `State` offers synchronous and asynchronous API, allowing you to compose the values in an imperative manner or as part of a combine stream.
`State` is also built for making state transactions so values can be updated and published together.

### Examples

```swift
// Get a single value
try state.get(.callback.path)

// Get a single value as a Swift.Result
state.result(for: .callback.path)

// Subscribe to the value
state.publisher(for: .consent.token, as: String.self)
    .sink(to: OpenBanking.handle(consent:), on: self)
    .store(in: &bag)
    
// Save a value
state.set(.id, to: output.id)

// Mutate multiple values using a transaction
banking.state.transaction { state in
    state.clear(.callback.path)
    state.clear(.consent.token)
}
```
