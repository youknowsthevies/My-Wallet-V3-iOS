# Analytics Module

The analytics module is responsible for sending user analytics events to Firebase and the internal analytics backend.

### Adding new events

When adding a new event it's highly recommended to wrap in the AnalyticsKit's extension of  `AnalyticsEvents` .
It's an empty class that acts as the namespace. It eases the process of finding events in the project.
The new event should conform to `AnalyticsEvent` protocol providing at least `name`.
There are additional optional parameters like `params` and `type` that are defaulted on the protocol level. 

```
extension AnalyticsEvents {
    enum YourAnalyticsEvent: AnalyticsEvent {
        case amazingEvent(awesomeParameter: String)
        case otherEvent
    }
    
    var name: String {
        switch self {
        case .amazingEvent:
            return "amazing_event"
        case .otherEvent:
            return "other_event"
        }
    }

    var params: [String: String]? {
        switch self {
        case let .amazingEvent(param):
            return ["param": param]
        case .otherEvent:
            return nil
        }
    }
    
    var type: AnalyticsEventType = .new
}
```

### Usage

The `AnalyticsEventRecording` type is automatically registered via `DIKit` and should be accessible after importing `AnalyticsKit` and resolving.
To track the event, just call the `record(event:)` function and pass the event as a parameter.

```
import AnalyticsKit

class ClassToBeAnalyzed {

    private let analyticsRecorder: AnalyticsEventRecording

    init(analyticsRecorder: AnalyticsEventRecording = resolve()) {
        self.analyticsRecorder = analyticsRecorder
    }
    
    func functionToBeTracked() {
        recorder.record(event: AnalyticsEvents.YourAnalyticsEvent.amazingEvent("paramName"))
    }
}
```

### Adding new providers

You can add multiple analytics providers, but implementing a class that conforms to  `AnalyticsServiceProviding` .
You need to register it `DIKit` together with other providers as `[AnalyticsServiceProviding]` type that's automatically resolved by `AnalyticsEventRecorder`. 

```
public class BlockchainAnalyticsProvider: AnalyticsServiceProviding {
    
    public var supportedEventTypes: [AnalyticsEventType] = [.new]
    
    public init() { }
    
    public func trackEvent(title: String, parameters: [String : Any]? = nil) {
        print("New Event:\n\(title)\n\(parameters)")
    }
}
```
