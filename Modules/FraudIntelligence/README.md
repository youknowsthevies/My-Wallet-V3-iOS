# FraudIntelligence

Observe app events and submit reports to sardine

Sardine SDK is abstracted via the MobileIntelligence_p protocol which is conformed to and injected in via the main target. This provides us with extra flexibility when it comes to linking the framework, disabling it inside of debug or running it under test.

The events which trigger new flows in sardine are provided via Firebase RemoteConfig in the shape of a Map where the key is the observed event and the value is the name of the flow to submit to sardine:

```json
{
  "blockchain.session.event.did.sign.in": "app",
  "blockchain.ux.transaction.event.did.start": "order"
}
```

Sardine also requires us to trigger a submission after it's collected data from the device, this can be done at any point in the app and all trigger points are defined as a set in Firebase RemoteConfig:

```json
[
  "blockchain.app.did.finish.launching",
  "blockchain.ux.transaction.event.did.finish"
]
```

This solution means we have the following flexibility:
1. We can remotely disable sardine integration
2. We can change when we set the flow inside of sardine sdk
3. We are able to configure when sardine recieves new data
4. No app code has to have knowledge of sardine, the namespace events decouple the solution from the rest of the application logic
