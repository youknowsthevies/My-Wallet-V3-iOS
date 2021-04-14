# TestKit

TestKit is a collection of Mocks and helpers that each module publishes to aid other modules Unit Testing functionality.

Instead of publishing those files as yet another framework, modules can make helpers available by storing them in a subfolders within `TestKit`.
Test Modules can link to that folder by adding it as a `source` in `project.yml` at the root of this repository. E.g.

```
MyKitTests:
  dependencies:
  - target: MyKit
  sources:
  - createIntermediateGroups: true
    path: TestKit/TestKit/Mocks/NetworkKit
  - createIntermediateGroups: true
    path: TestKit/TestKit/Mocks/PlatformKit
  - createIntermediateGroups: true
    path: TestKit/TestKit/Mocks/PlatformKit
  - createIntermediateGroups: true
    path: TestKit/TestKit/Mocks/ToolKit
  templateAttributes:
    featureName: MyFeature
  templates:
  - ModuleTests
```

# Why do we have a TestKit folder inside of a TestKit folder?

The reason behind this weird configuration is that, for some reason, `xcodegen` doesn't select the correct path for `group` sources that are stored at the top level of the repository when the flag `createIntermediateGroups` is set to `true`.
