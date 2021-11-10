# OpenBanking

A package providing access to the OpenBanking API, the current implementation uses the YAPILY specification available from `nabu-gateway/payments/banktransfer/`
This module utilises `Session.State` to conduct transactions on the data set as a side-effect of the queries or from an external service such as a deep link.

## Testing

All the tests are powered by the `ReplayNetworkCommunicator` class which simulates a running network by loading files from disk when required, the tests also take advantage of `TestScheduler` from PointFree to control time.

In the tests you can find some scripted examples of conducting a link and payment, these are prefixed with `x_` so they are not run at all. If you want to try these out, please remove the prefix. These are a great way to play with the API. 

## Documentation

As part of this work a sequence diagram was created in order to understand the flow of events between client and server, expand the section below to reveal the image and mermaid.js UML 

<details>
  <summary>Click to see!</summary>
  
  ![Sequence Diagram](.resources/diagram.png?raw=true)
  
  ```
  sequenceDiagram
      autonumber
      participant Client
      participant Nabu
      participant Bank
      Client->>Nabu: POST /nabu-gateway/payments/banktransfer
      Nabu-->>Client: 
      Note right of Client: account.id<br />institutions
      Client->Client: Select institution
      Client->>Nabu: POST /nabu-gateway/payments/banktransfer/{account.id}/update
      Nabu-->>Client: 
      loop until state.ACTIVE
          Client->>Nabu: GET /nabu-gateway/payments/banktransfer/{account.id}/update
          Nabu-->>Client: 
          Note right of Client: authorisationUrl?<br />callbackPath?
          alt has authorisationUrl
              Client->>Bank: Launch authorisationUrl
                  Bank-->>Client: Launch via deep link
                  note right of Client: consent token
                  Client->>Nabu: POST callbackPath
                  note left of Nabu: consent token
          end
          Client->Client: Delay
      end
      Client->>Nabu: POST /nabu-gateway/payments/banktransfer/{account.id}/payment
      note left of Nabu: currency<br />amountMinor<br />product
      Nabu-->>Client: 
      loop until state.CLEARED
          Client->>Nabu: GET /nabu-gateway/payments/payment/{payment.id}
          Nabu-->>Client: 
          Note right of Client: authorisationUrl?<br />callbackPath?
          alt has authorisationUrl
              Client->>Bank: Launch authorisationUrl
              Bank-->>Client: Launch via deep link
              note right of Client: consent token
              Client->>Nabu: POST callbackPath
              note left of Nabu: consent token
          end
          Client->Client: Delay
      end
  ```
</details>

