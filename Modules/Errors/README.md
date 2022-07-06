# Errors

Provides both low level `NetworkError` as well as the higher level `NabuNetworkError` (for all Nabu Gateway APIs).

Other higher level error types can be created from `NetworkError`  by conforming to `FromNetworkErrorConvertible`.
