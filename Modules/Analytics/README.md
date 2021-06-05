# Analytics Module

The analytics module is responsible for sending user analytics events to Firebase and the internal analytics backend.

### Adding new events

When adding a new event it's highly recommended to wrap it in the AnalyticsKit's extension of  `AnalyticsEvents.New` .
It's an empty class that acts as the namespace. It eases the process of finding events in the project.
The new event enum that conforms to `AnalyticsEvent` by default will output it's name and parameters using reflection.

Scheme for automatic generation:
Name uses space case: `amazingEvent` -> `"Amazing Event"`
Params use snake case: `awesomeParameter` -> `"awesome_parameter"`

Automatically supported parameter values are: `Bool`, `Int`, `Double`, `String` and `StringRawRepresentable` for custom enums.

It's allowed to override `name` and `params` to achieve custom output.


```
extension AnalyticsEvents.New {
    enum YourAnalyticsEvent: AnalyticsEvent {
        var type: AnalyticsEventType { .new }
    
        case amazingEvent(awesomeParameter: AwesomeParameterType, value: Double)
        case otherEvent
    }
    
    public enum AwesomeParameterType: String, StringRawRepresentable {
        case firstType = "FIRST"
        case secondType = "SECOND"
    }
    
    // Optional
    var name: String {
        switch self {
        case .amazingEvent:
            return "🤓 custom name of the event 🤓"
        case .otherEvent:
            return "other_event"
        }
    }

    // Optional
    var params: [String: String]? {
        switch self {
        case let .amazingEvent(awesomeParameter, value):
            return [
                "parameter": awesomeParameter.rawValue,
                "value": value
            ]
        case .otherEvent:
            return nil
        }
    }
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
