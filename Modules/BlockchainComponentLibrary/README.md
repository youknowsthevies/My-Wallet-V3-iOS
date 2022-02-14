# BlockchainComponentLibrary

A design-driven component library, imported by both wallet-ios and exchange-ios.

## References:

 - [Figma](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=0%3A1)
 - [Proposal](https://www.notion.so/blockchaincom/Proposal-IOS-5493-Design-Driven-Component-Library-5d030d637b8840d482f4b1340842a9d5)

## Examples

An `Examples` module is included in the package. One can run iOS simulator previews on `RootView` to view the samples.

## Adding a Component

- Add the component and previews to the appropriate folder
- Include snapshot tests for all variants
- Include samples in the Examples module

## Folder & Component structure

### 1 - Base

Base components have no other component dependencies. Things such as Colors, text styles, assets, and layout constants belong here.
Usually, these are only being consumed by other components, not accessed externally.

### 2 - Primitives

Primitives depend only on Base components. They are intended to be used directly and composed into bigger views.

### 3 - Compositions

Compositions are made up of both primitives and base components. These are your larger, potentially more complicated views.

## Components

- Only exist if they exist in the Figma linked above
- Naming and location match Figma.
    - EG: `Button / Primary` → `PrimaryButton`
- Contain no logic. Basic inputs, logic comes from the consumer.
- No dependencies (such as TCA). Raw SwiftUI components
- Support Dark & Light mode
- Support Dynamic Text
- Support Accessibility requirements (LTR/RTL, labels, localization etc)
- Are well tested. (snapshots)
- Are well documented
    - Figma Name: `Button / Primary`
    - Figma Version: 1.0.0
    - Code docs (parameters, etc)
    - Link to basic snapshot
    - link to figma component
