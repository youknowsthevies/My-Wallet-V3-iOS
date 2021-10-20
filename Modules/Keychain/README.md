### Keychain Access 

This module provides an easy way to read and write values to the Keychain.  

_Note_ 
Unit Testing the Keychain requires a test host app in order to get correct entitlements, which unfortunately SPM doesn't support.
As a workaround the underlying core methods to interface with the Keychain have been moved into global methods and
are mocked in tests to verify the expected behaviour.

### Key Classes

- `KeychainAccess`
Provides both read and write access, under the hood it uses  `KeychainReader` and `KeychainWriter` to perform its operation  

### Sample usage

Writing a value to the keychain, using the default method
``` 
let keychainAccess = KeychainAccess(service: "some-service")

// write some data for a specified key using the default security class of kSecClassGenericPassword
let someValue = "value".data(using: .utf8)!
let result = keychainAccess.write(value: someValue, for: "some-key")
// check if the write was successful
switch result {
case .success:
    // the write operation was successful  
    break
case .failure(let error):
    print(error.localizedDescription)
}
```

Reading a value from the keychain 

```
let keychainAccess = KeychainAccess(service: "some-service")

let result = keychainAccess.read(for: "some-key")
// check if the write was successful
switch result {
case .success(let value):
    let stringValue = String(data: value, encoding: .utf8)
    print(stringValue)
case .failure(let error):
    print(error.localizedDescription)
}
```

Removing a value from the keychain

```
let keychainAccess = KeychainAccess(service: "some-service")

let result = keychainAccess.remove(for: "some-key")
// check if the deletion was successful
switch result {
case .success:
    // the delete operation was successful
    break
case .failure(let error):
    print(error.localizedDescription)
}
```
