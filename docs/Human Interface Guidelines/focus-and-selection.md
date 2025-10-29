---
url: "https://developer.apple.com/design/human-interface-guidelines/focus-and-selection"
title: "Focus and selection | Apple Developer Documentation"
---

[Skip Navigation](https://developer.apple.com/design/human-interface-guidelines/focus-and-selection#app-main)

- [Global Nav Open Menu](https://developer.apple.com/design/human-interface-guidelines/focus-and-selection#ac-gn-menustate) [Global Nav Close Menu](https://developer.apple.com/design/human-interface-guidelines/focus-and-selection#)
- [Apple Developer](https://developer.apple.com/)

[Search Developer\\
\\
Cancel](https://developer.apple.com/search/)

- [Apple Developer](https://developer.apple.com/)
- [News](https://developer.apple.com/news/)
- [Discover](https://developer.apple.com/discover/)
- [Design](https://developer.apple.com/design/)
- [Develop](https://developer.apple.com/develop/)
- [Distribute](https://developer.apple.com/distribute/)
- [Support](https://developer.apple.com/support/)
- [Account](https://developer.apple.com/account/)
- [Search Developer](https://developer.apple.com/search/)

Cancel

Only search within “Human Interface Guidelines”

### Quick Links

- [Downloads](https://developer.apple.com/download/)
- [Documentation](https://developer.apple.com/documentation/)
- [Sample Code](https://developer.apple.com/documentation/samplecode/)
- [Videos](https://developer.apple.com/videos/)
- [Forums](https://developer.apple.com/forums/)

5 Quick Links

[Design](https://developer.apple.com/design/)

[Open Menu](https://developer.apple.com/design/human-interface-guidelines/focus-and-selection#)

- [Overview](https://developer.apple.com/design/)
- [What’s New](https://developer.apple.com/design/whats-new/)
- [Get Started](https://developer.apple.com/design/get-started/)
- [Guidelines](https://developer.apple.com/design/human-interface-guidelines)
- [Resources](https://developer.apple.com/design/resources/)

## Human Interface Guidelines

To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow

6 of 6 symbols inside <root> containing 29 symbols [Technologies](https://developer.apple.com/design/human-interface-guidelines/technologies)

To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow

13 of 13 symbols inside 182752026 [Remotes](https://developer.apple.com/design/human-interface-guidelines/remotes)

To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow

12 of 13 symbols inside 182752026 [Pointing devices](https://developer.apple.com/design/human-interface-guidelines/pointing-devices)

To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow

11 of 13 symbols inside 182752026 [Nearby interactions](https://developer.apple.com/design/human-interface-guidelines/nearby-interactions)

To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow

10 of 13 symbols inside 182752026 [Keyboards](https://developer.apple.com/design/human-interface-guidelines/keyboards)

To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow

9 of 13 symbols inside 182752026 [Gyroscope and accelerometer](https://developer.apple.com/design/human-interface-guidelines/gyro-and-accelerometer)

To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow

8 of 13 symbols inside 182752026 [Gestures](https://developer.apple.com/design/human-interface-guidelines/gestures)

To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow

7 of 13 symbols inside 182752026 [Game controls](https://developer.apple.com/design/human-interface-guidelines/game-controls)

To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow

6 of 13 symbols inside 182752026 [Focus and selection](https://developer.apple.com/design/human-interface-guidelines/focus-and-selection)

To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow

5 of 13 symbols inside 182752026 [Eyes](https://developer.apple.com/design/human-interface-guidelines/eyes)

To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow

4 of 13 symbols inside 182752026 [Digital Crown](https://developer.apple.com/design/human-interface-guidelines/digital-crown)

To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow

3 of 13 symbols inside 182752026 [Camera Control](https://developer.apple.com/design/human-interface-guidelines/camera-control)

To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow

2 of 13 symbols inside 182752026 [Apple Pencil and Scribble](https://developer.apple.com/design/human-interface-guidelines/apple-pencil-and-scribble)

To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow

1 of 13 symbols inside 182752026 [Action button](https://developer.apple.com/design/human-interface-guidelines/action-button)

To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow

5 of 6 symbols inside <root> containing 13 symbols [Inputs](https://developer.apple.com/design/human-interface-guidelines/inputs)

To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow

4 of 6 symbols inside <root> containing 8 symbols [Components](https://developer.apple.com/design/human-interface-guidelines/components)

To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow

3 of 6 symbols inside <root> containing 25 symbols [Patterns](https://developer.apple.com/design/human-interface-guidelines/patterns)

To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow

2 of 6 symbols inside <root> containing 18 symbols [Foundations](https://developer.apple.com/design/human-interface-guidelines/foundations)

To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow

1 of 6 symbols inside <root> containing 7 symbols [Getting started](https://developer.apple.com/design/human-interface-guidelines/getting-started)

19 items were found. Tab back to navigate through them.

Navigator is ready

# Focus and selection

Focus helps people visually confirm the object that their interaction targets.

![A sketch of a frame around a circular interface element, suggesting locking focus on an object. The image is overlaid with rectangular and circular grid lines and is tinted purple to subtly reflect the purple in the original six-color Apple logo.](https://docs-assets.developer.apple.com/published/13b5befef4936f31ce74db6aa05b7a0e/inputs-focus-and-selection-intro%402x.png)

Focus supports simplified, component-based navigation. Using inputs like a remote, game controller, or keyboard, people bring focus to the components they want to interact with.

In many cases, focusing an item also selects it. The exception is when automatic selection might cause a distracting context shift, like opening a new view. In tvOS, for example, people use the remote to move focus from item to item as they seek the one they want, but because selecting a focused item opens or activates it, selection requires a separate gesture.

Different platforms communicate focus in different ways. For example, iPadOS and macOS show focus by drawing a ring around an item or highlighting it; tvOS generally uses the [parallax effect](https://developer.apple.com/design/human-interface-guidelines/images#Parallax-effect) to give the focused item an appearance of depth and liveliness. The combination of focus effects and interactions is sometimes called a _focus system_ or _focus model_.

## [Best practices](https://developer.apple.com/design/human-interface-guidelines/focus-and-selection\#Best-practices)

**Rely on system-provided focus effects.** System-defined focus effects are precisely tuned to complement interactions with Apple devices, providing experiences that feel responsive, fluid, and lifelike. Incorporating system-provided focus behaviors gives your app consistency and predictability, helping people understand it quickly. Consider creating custom focus effects only if it’s absolutely necessary.

**Avoid changing focus without people’s interaction.** People rely on the focus system to help them know where they are in your app. If you change focus without their interaction, people have to spend time finding the newly focused item, delaying their current task. The exception is when people are moving focus using an input device that lets them make discrete, directional movements — like a keyboard, remote, or game controller — and a previously focused item disappears. In this scenario, there are only a small number of items within one discrete step of the previously focused item, so moving focus to one of these remaining items ensures that the focus indicator is in a location people can easily find. When people aren’t moving focus by using such an input device, you can’t predict the item they’ll target next, so it’s generally best to simply hide the focus indicator when the focused object disappears.

**Be consistent with the platform as you help people bring focus to items in your app.** For example, in iPadOS and macOS, a full keyboard access mode helps people use the keyboard to reach every control, so you only need to support focus for content elements like list items, text fields, and search fields, and not for controls like buttons, sliders, and toggles. In contrast, tvOS users rely on using directional gestures on a remote or game controller (or pressing the arrow keys on an attached keyboard) to reach every onscreen element, so you need to make sure that people can bring focus to every element in your app.

**Indicate focus using visual appearances that are consistent with the platform.** For example, consider a window that contains a list of items. In iPadOS and macOS, the system draws focused list items using white text and a background highlight that matches the app’s accent color, drawing unfocused items using the standard text color and a gray background highlight (for developer guidance, see [`UICollectionView`](https://developer.apple.com/documentation/UIKit/UICollectionView) and [`NSTableView`](https://developer.apple.com/documentation/AppKit/NSTableView)).

**In general, use a focus ring for a text or search field, but use a highlight in a list or collection.** Although you can use a focus ring to draw attention to an item that fills a cell, like a photo, it’s usually easier for people to view lists and collections when an entire row is highlighted.

## [Platform considerations](https://developer.apple.com/design/human-interface-guidelines/focus-and-selection\#Platform-considerations)

_Not supported in iOS or watchOS._

### [iPadOS](https://developer.apple.com/design/human-interface-guidelines/focus-and-selection\#iPadOS)

iPadOS 15 and later defines a focus system that supports keyboard interactions for navigating text fields, text views, and sidebars, in addition to various types of collection views and other custom views in your app.

The iPadOS and tvOS focus systems are similar. People perform actions by moving a focus indicator to an item and then selecting it (for guidance, see [tvOS](https://developer.apple.com/design/human-interface-guidelines/focus-and-selection#tvOS)). Although the underlying system is the same, the user experiences are a little different. tvOS uses _directional focus_, which means people can use the same interaction — that is, swiping the Siri Remote or using only the arrow keys on a connected keyboard — to navigate to every onscreen component. In contrast, iPadOS defines _focus groups_, which represent specific areas within an app, like a sidebar, grid, or list. Using focus groups, iPadOS can support two different keyboard interactions.

- Pressing the Tab key moves focus among focus groups, letting people navigate to sidebars, grids, and other app areas.

- Pressing an arrow key supports a directional focus interaction that’s similar to tvOS, but limited to navigation among items in the same focus group. For example, people can use an arrow key to move through the items in a list or a sidebar.


Onscreen components can indicate focus by using the halo effect or the highlighted appearance.

The _halo_ focus effect — also known as the _focus ring_ — displays a customizable outline around the component. You can apply the halo effect to custom views and to fully opaque content within a collection or list cell, such as an image.

![An illustration of a collection view of photos showing the standard halo effect that outlines the focused photo.](https://docs-assets.developer.apple.com/published/2bfe6fedc5a6a8ecf6d7e74e9492a096/focus-and-selection-halo-focus-effect%402x.png)

**Customize the halo focus effect when necessary.** By default, the system uses an item’s shape to infer the shape of its halo. If the system-provided halo doesn’t give you the appearance you want, you can refine it to match contours like rounded corners or shapes defined by Bézier paths. You can also adjust a halo’s position if another component occludes or clips it. For example, you might need to ensure that a badge appears above the halo or that a parent view doesn’t clip it. For developer guidance, see [`UIFocusHaloEffect`](https://developer.apple.com/documentation/UIKit/UIFocusHaloEffect).

![An illustration of a collection view of photos showing a rounded-rectangle halo effect that outlines the focused photo.](https://docs-assets.developer.apple.com/published/1a84f872d0624355e89fa03b357ddd13/focus-and-selection-customized-halo%402x.png)

The _highlighted_ appearance — in which the component’s text uses the app’s accent color — also indicates focus, but it’s not a focus effect. The highlight appearance occurs automatically when people select a collection view cell on which you’ve set content configurations (for developer guidance, see [`UICollectionViewCell`](https://developer.apple.com/documentation/UIKit/UICollectionViewCell)).

![An illustration of a list of menu items with the second item highlighted. The item's title and icon are tinted with a red accent color.](https://docs-assets.developer.apple.com/published/01261865c38379fa118f16057a54f23e/focus-and-selection-highlighted-appearance%402x.png)

**Ensure that focus moves through your custom views in ways that make sense.** As people continue pressing the Tab key, focus moves through focus groups in reading order: leading to trailing, and top to bottom. Although focus moves through system-provided views in ways that people expect, you might need to adjust the order in which the focus system visits your custom views. For example, if you want focus to move down through a vertical stack of custom views before it moves in the trailing direction to the next view, you need to identify the stack container as a single focus group. For developer guidance, see [`focusGroupIdentifier`](https://developer.apple.com/documentation/UIKit/UIFocusEnvironment/focusGroupIdentifier).

**Adjust the priority of an item to reflect its importance within a focus group.** When a group receives focus, its _primary item_ automatically receives focus too, making it easy for people to select the item they’re most likely to want. You can make an item primary by increasing its priority. For developer guidance, see [`UIFocusGroupPriority`](https://developer.apple.com/documentation/UIKit/UIFocusGroupPriority).

### [tvOS](https://developer.apple.com/design/human-interface-guidelines/focus-and-selection\#tvOS)

**In a full-screen experience, let people use gestures to interact with the content, not to move focus.** When an item displays in full screen, it doesn’t show focus, so people naturally assume that their gestures will affect the object, and not its focus state.

**Avoid displaying a pointer.** People expect to navigate a fixed number of items by changing focus, not by trying to drag a tiny pointer around a huge screen. While free-form movement might make sense during gameplay, such as when looking for a hidden object or flying a plane, use the focus model when people navigate menus and other interface elements. If your app requires a pointer, make sure it’s highly visible and feels integrated with your experience.

**Design your interface to accommodate components in various focus states.** In tvOS, focusable items can have up to five different states, each of which is visually distinct. Because focusing an item often increases its scale, you need to supply assets for the larger, focused size to ensure they always look sharp, and you need to make sure the larger item doesn’t crowd the surrounding interface.

| State | Description |
| --- | --- |
| ![An image of an unfocused button on top of a photograph. A small drop shadow makes it appear very close to the content behind it, with a translucent background infused by the colors of the content, and a high-contrast text color.](https://docs-assets.developer.apple.com/published/bfc53c88dc7a84a9ca45d43d8f7fb550/focus-and-selection-state-unfocused%402x.png) | The viewer hasn’t brought focus to the item. Unfocused items appear less prominent than focused items. |
| ![An image of a focused button on top of a photograph. It’s larger than an unfocused button, and a drop shadow makes it appear farther away from the content behind it, with an opaque white background and a black text label.](https://docs-assets.developer.apple.com/published/882b1286aa16b7a8d4a6367778a984b9/focus-and-selection-state-focused%402x.png) | The viewer brings focus to the item. A focused item visually stands out from the other onscreen content through elevation to the foreground, illumination, and animation. |
| ![An image of a highlighted button on top of a photograph. It’s the same size as an unfocused button, and a drop shadow makes it appear a little farther away from the surface of the content behind it, with an opaque white background and a black text label.](https://docs-assets.developer.apple.com/published/d5388fe044717ba970895f33bdbebe3c/focus-and-selection-state-highlighted%402x.png) | The viewer chooses the focused item. A focused item provides instant visual feedback when people choose it. For example, a button might briefly invert its colors and animate before it transitions to its selected appearance. |
| ![An image of a selected button on top of a photograph. It’s the same size as an unfocused button, and a small drop shadow makes it appear very close to the content behind it, with an opaque white background and a black text label.](https://docs-assets.developer.apple.com/published/ea6520ec5576b19ad7952c35a28c2dfc/focus-and-selection-state-selected%402x.png) | The viewer has chosen or activated the item in some way. For example, a heart-shaped button that people can use to favorite a photo might appear filled in the selected state and empty in the deselected state. |
| ![An image of an unavailable button on top of a photograph. It’s the same size as an unfocused button. It lacks a drop shadow and appears to rest directly on the content behind it, with a translucent background tinted by the the colors of nearby content, and a low-contrast text color.](https://docs-assets.developer.apple.com/published/c1d9c327cbefe45ef0aeef12b93b956c/focus-and-selection-state-unavailable%402x.png) | The viewer can’t bring focus to the item or choose it. An unavailable item appears inactive. |

For developer guidance, see [Adding user-focusable elements to a tvOS app](https://developer.apple.com/documentation/UIKit/adding-user-focusable-elements-to-a-tvos-app).

### [visionOS](https://developer.apple.com/design/human-interface-guidelines/focus-and-selection\#visionOS)

visionOS supports the same focus system as in iPadOS and tvOS, letting people use a connected input device like a keyboard or game controller to interact with apps and the system.

Note

When people look at a virtual object to identify it as the object they want to interact with, the system uses the _hover effect_, not a focus effect, to provide visual feedback (for guidance, see [Eyes](https://developer.apple.com/design/human-interface-guidelines/eyes)). The hover effect isn’t related to the focus system.

## [Resources](https://developer.apple.com/design/human-interface-guidelines/focus-and-selection\#Resources)

#### [Related](https://developer.apple.com/design/human-interface-guidelines/focus-and-selection\#Related)

[Eyes](https://developer.apple.com/design/human-interface-guidelines/eyes)

[Keyboards](https://developer.apple.com/design/human-interface-guidelines/keyboards)

#### [Developer documentation](https://developer.apple.com/design/human-interface-guidelines/focus-and-selection\#Developer-documentation)

[Focus Attributes](https://developer.apple.com/documentation/TVML/focus-attributes) — TVML

[Focus-based navigation](https://developer.apple.com/documentation/UIKit/focus-based-navigation) — UIKit

[About focus interactions for Apple TV](https://developer.apple.com/documentation/UIKit/about-focus-interactions-for-apple-tv) — UIKit

#### [Videos](https://developer.apple.com/design/human-interface-guidelines/focus-and-selection\#Videos)

[![](https://devimages-cdn.apple.com/wwdc-services/images/D35E0E85-CCB6-41A1-B227-7995ECD83ED5/C6CDCC79-CCD0-4D2F-A4D1-8FC70DC663DB/8127_wide_250x141_1x.jpg)\\
\\
Design for spatial input](https://developer.apple.com/videos/play/wwdc2023/10073)

[![](https://devimages-cdn.apple.com/wwdc-services/images/D35E0E85-CCB6-41A1-B227-7995ECD83ED5/38E4EE32-29B5-4478-B8B6-35B8ACA67B16/8130_wide_250x141_1x.jpg)\\
\\
Design for spatial user interfaces](https://developer.apple.com/videos/play/wwdc2023/10076)

[![](https://devimages-cdn.apple.com/wwdc-services/images/49/F9A980A7-B00A-4856-9172-FDB610A419E5/3509_wide_250x141_1x.jpg)\\
\\
Design for the iPadOS pointer](https://developer.apple.com/videos/play/wwdc2020/10640)

## [Change log](https://developer.apple.com/design/human-interface-guidelines/focus-and-selection\#Change-log)

| Date | Changes |
| --- | --- |
| October 24, 2023 | Clarified the difference between focus effects and the visionOS hover effect. |
| June 21, 2023 | Updated to include guidance for visionOS. |

Current page is Focus and selection

##### Supported platforms

- [Focus and selection](https://developer.apple.com/design/human-interface-guidelines/focus-and-selection#app-top)
- [Best practices](https://developer.apple.com/design/human-interface-guidelines/focus-and-selection#Best-practices)
- [Platform considerations](https://developer.apple.com/design/human-interface-guidelines/focus-and-selection#Platform-considerations)
- [Resources](https://developer.apple.com/design/human-interface-guidelines/focus-and-selection#Resources)
- [Change log](https://developer.apple.com/design/human-interface-guidelines/focus-and-selection#Change-log)

[Apple](https://www.apple.com/)

1. [Developer](https://developer.apple.com/)
2. [Documentation](https://developer.apple.com/documentation/)

### Platforms

Toggle Menu

- [iOS](https://developer.apple.com/ios/)
- [iPadOS](https://developer.apple.com/ipados/)
- [macOS](https://developer.apple.com/macos/)
- [tvOS](https://developer.apple.com/tvos/)
- [visionOS](https://developer.apple.com/visionos/)
- [watchOS](https://developer.apple.com/watchos/)

### Tools

Toggle Menu

- [Swift](https://developer.apple.com/swift/)
- [SwiftUI](https://developer.apple.com/swiftui/)
- [Swift Playground](https://developer.apple.com/swift-playground/)
- [TestFlight](https://developer.apple.com/testflight/)
- [Xcode](https://developer.apple.com/xcode/)
- [Xcode Cloud](https://developer.apple.com/xcode-cloud/)
- [SF Symbols](https://developer.apple.com/sf-symbols/)

### Topics & Technologies

Toggle Menu

- [Accessibility](https://developer.apple.com/accessibility/)
- [Accessories](https://developer.apple.com/accessories/)
- [App Extension](https://developer.apple.com/app-extensions/)
- [App Store](https://developer.apple.com/app-store/)
- [Audio & Video](https://developer.apple.com/audio/)
- [Augmented Reality](https://developer.apple.com/augmented-reality/)
- [Design](https://developer.apple.com/design/)
- [Distribution](https://developer.apple.com/distribute/)
- [Education](https://developer.apple.com/education/)
- [Fonts](https://developer.apple.com/fonts/)
- [Games](https://developer.apple.com/games/)
- [Health & Fitness](https://developer.apple.com/health-fitness/)
- [In-App Purchase](https://developer.apple.com/in-app-purchase/)
- [Localization](https://developer.apple.com/localization/)
- [Maps & Location](https://developer.apple.com/maps/)
- [Machine Learning & AI](https://developer.apple.com/machine-learning/)
- [Open Source](https://opensource.apple.com/)
- [Security](https://developer.apple.com/security/)
- [Safari & Web](https://developer.apple.com/safari/)

### Resources

Toggle Menu

- [Documentation](https://developer.apple.com/documentation/)
- [Tutorials](https://developer.apple.com/learn/)
- [Downloads](https://developer.apple.com/download/)
- [Forums](https://developer.apple.com/forums/)
- [Videos](https://developer.apple.com/videos/)

### Support

Toggle Menu

- [Support Articles](https://developer.apple.com/support/articles/)
- [Contact Us](https://developer.apple.com/contact/)
- [Bug Reporting](https://developer.apple.com/bug-reporting/)
- [System Status](https://developer.apple.com/system-status/)

### Account

Toggle Menu

- [Apple Developer](https://developer.apple.com/account/)
- [App Store Connect](https://appstoreconnect.apple.com/)
- [Certificates, IDs, & Profiles](https://developer.apple.com/account/ios/certificate/)
- [Feedback Assistant](https://feedbackassistant.apple.com/)

### Programs

Toggle Menu

- [Apple Developer Program](https://developer.apple.com/programs/)
- [Apple Developer Enterprise Program](https://developer.apple.com/programs/enterprise/)
- [App Store Small Business Program](https://developer.apple.com/app-store/small-business-program/)
- [MFi Program](https://mfi.apple.com/)
- [News Partner Program](https://developer.apple.com/programs/news-partner/)
- [Video Partner Program](https://developer.apple.com/programs/video-partner/)
- [Security Bounty Program](https://developer.apple.com/security-bounty/)
- [Security Research Device Program](https://developer.apple.com/programs/security-research-device/)

### Events

Toggle Menu

- [Meet with Apple](https://developer.apple.com/events/)
- [Apple Developer Centers](https://developer.apple.com/events/developer-centers/)
- [App Store Awards](https://developer.apple.com/app-store/app-store-awards/)
- [Apple Design Awards](https://developer.apple.com/design/awards/)
- [Apple Developer Academies](https://developer.apple.com/academies/)
- [WWDC](https://developer.apple.com/wwdc/)

To submit feedback on documentation, visit [Feedback Assistant](applefeedback://new?form_identifier=developertools.fba&answers%5B%3Aarea%5D=seedADC%3Adevpubs&answers%5B%3Adoc_type_req%5D=Technology%20Documentation&answers%5B%3Adocumentation_link_req%5D=https%3A%2F%2Fdeveloper.apple.com%2Fdesign%2Fhuman-interface-guidelines%2Ffocus-and-selection).

Select a color scheme preference
Light

Dark

Auto

English  简体中文  日本語  한국어

Copyright © 2025 [Apple Inc.](https://www.apple.com/) All rights reserved.

[Terms of Use](https://www.apple.com/legal/internet-services/terms/site.html) [Privacy Policy](https://www.apple.com/legal/privacy/) [Agreements and Guidelines](https://developer.apple.com/support/terms/)