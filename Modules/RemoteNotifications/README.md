# Remote Notifications Module

The remote notifications module is responsible for managing remote notifications for users, including authorization, token sending and receiving, network requests and responses, and apple push notifications service (APNs).

### Implementation Details

`RemoteNotificationServiceContainer` exposes a number of class objects to the main target. All interfaces are exposed via Swift `protocol`. The framework provides default implmentation for such classes.

The exposed class objects are:
```
public protocol RemoteNotificationServiceContaining {
    /// Authorizer of remote notifications
    var authorizer: RemoteNotificationAuthorizing { get }
    
    /// Receiver of data/background notifications
    var backgroundReceiver: RemoteNotificationBackgroundReceiving { get }
    
    /// Sender of token to remote server
    var tokenSender: RemoteNotificationTokenSending { get }
    
    /// Receiver of token from remote server
    var tokenReceiver: RemoteNotificationDeviceTokenReceiving { get }
}
```
