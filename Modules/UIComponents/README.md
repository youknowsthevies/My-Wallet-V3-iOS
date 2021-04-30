# UIComponents

This moudule encapsulates an iOS implementation of Blockchain.com's brand's design system. It contains colors, font styles, UI component styles and custom UI components. It's meant to be the base layer for all Feature Modules' UIs. It supports both `UIKit` and `SwiftUI`.

`UIComponentsKit` should only ever contain styling helpers and basic UI elements that compose a larger views - e.g. custom buttons and controls - but not entire views. Think about this module as a collection of Lego bricks: it's up to each Feature Module to put them together to compose anything. 
