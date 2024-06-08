<p align="center"><img src="https://gateway.ipfs.io/ipfs/QmUR5vx55UVCeo1gWSk5zmoc5hKh4XXf1mrFrU3pBQpy2r" height="120px" /></p>

<h1 align="center">Loom (iOS & macOS) Beta</h1>

<p align="center"><img src="https://gateway.ipfs.io/ipfs/QmZ46tDJLuGcnggQSWUwi3tKUdTq5upsX8S1YNeevT6jqx" width="90%" /></p>

<p align="center">Aggregating aggregation. Providing everyone with a premium experience when interacting with federated servers. Meanwhile, providing view libraries and solutions for others to implement their own interpretations in the Apple ecosystem.</p>

## Requirements
![Swift Compatibility](https://img.shields.io/badge/Swift-5.9%20%7C%205.8%20%7C%205.7-orange?logo=swift)
![Platform Compatibility](https://img.shields.io/badge/Platform-iOS%20%7C%20macOS-blue)
[![License](https://img.shields.io/badge/License-MIT--Clause-orange.svg)](https://opensource.org/license/mit/)

> My local environment: Xcode 14.2 or later // macOS (Intel) 12.6 or later // iOS 15.4 or later

## Disclaimers
- Due to the nature of possible state schemas being changed. Saved data such as account information or bookmarks may be removed in future release versions (or not at all).
- Keychain access warning. Keychain is only used for STORING your passwords and nothing else.

## Features
- Translated into 28 languages (MTL)
- Bookmarks are locally stored for offline viewing
- IPFS Content generation (Add your own config, gateway, etc)
- Login, Create Posts, Comments, Interact, update profiles as normal

| Expanded Layout (iPad/macOS)   | |
| :-------- | -------: |
| ![Image](https://gateway.ipfs.io/ipfs/QmXjYReP9dcu2jiW52yUNTNZdZTYqEvVEoNsohSjzaXMnC) | [Granite](https://github.com/pexavc/Granite) supports macOS. Same navigation API can direct window spawning or navigation stack pushing. |
| ![Image](https://gateway.ipfs.io/ipfs/QmcaJEm7Mq4qsgnKbLUe8TcoYJxP2m6b9SSiEwazdXe7hv) | Spawn multiple windows of entire feed layouts with multiple communities to observe. Will be helpful in the case of moderating multiple communities for instance. |

| Looms    | |
| :-------- | -------: |
| ![Image](https://gateway.ipfs.io/ipfs/QmbkjKBrrmnxoo28rc1xuxqJDHoz4P2LdMLctyQATu8HC2) | Create "Looms" of any group of communities from any instance. Merging their content into a singular feed.|

| Explore    | |
| :-------- | -------: |
| ![Image](https://gateway.ipfs.io/ipfs/QmXoHKNAo2RHYAd843Mv4tzxAvRKswT1U8zVrEMnj4UFDQ)  | Visit linked instances when connected to a lemmy server. View small snippets of each and their ping response time.   |

| Aggregation Sources (Aside from Lemmy)    | |
| :-------- | -------: |
| ![Image](https://gateway.ipfs.io/ipfs/QmZJibCj8KWHp55541epsWQ9rpv3czHJ6UXCtcXR66cSu2)  | RSS feeds can be pulled when setting the instance URL to a valid endpoint. Pagination is not currently supported, but will be in the future. Looking at supporting Atom/JSON streams as well.   |
| ![Image](https://gateway.ipfs.io/ipfs/QmNqTdTswLR62J6ES3ap6DGcfgeUd3ifAkGGgwfMVy24rX)  | Mastodon feeds can be pulled when setting the instance URL to a valid mastodon instance. Pagination is not currently supported, but will be in the future. Interactions are disabled for the time being `2023-9-4`.   |

| Safety    | |
| :-------- | -------: |
| ![Image](https://gateway.ipfs.io/ipfs/QmZqQePckASn8Xtd4d1Pp4m1meHm5GVnzozWQzs3MEfLJ8)  | On-device CoreML models + keyword filtering to remove posts from the feed. `NSFW Extended` will remove posts that are detected as NSFW even if they are not flagged as so.     |

| Styling    | |
| :-------- | -------: |
| ![Image](https://gateway.ipfs.io/ipfs/QmPFxEsXtDBJf8oSnAJihwv5FoCtugAqUPBhobtw275CpT)  |  Intended to allow full user customization in the future. Currently supports a "social app feel" and a "reddit-like reader".   |

| MD helper  | |
| :-------- | -------: |
| ![Image](https://gateway.ipfs.io/ipfs/QmZ5H7u64ceJ6nvVkBpdtzWSc7FkHhih4SFnNo7HdgEB7B) | Keyboard toolbar provides easy to access shortcuts on iPhone/iPad to help with Markdown formatting. |

| Travelling Modals    | |
| :-------- | -------: |
| ![Image](https://gateway.ipfs.io/ipfs/QmdXUT8RbYT6orPhHQMQig6TMMyg6crUhssmbC96bT266s)  | Writing modals can travel with your viewing context. Allowing you to browse content in any stack prior to publishing.   |

| Bookmark Syncing    | |
| :-------- | -------: |
| ![Image](https://gateway.ipfs.io/ipfs/QmVeqWMZZ2TipxVK5aRfbFxtQBTsvJ1snYDaVCs16jRmK7)  | All your saved posts and comments can be switched between accounts in a dedicated component.   |

| Sharing    | |
| :-------- | -------: |
| ![Image](https://gateway.ipfs.io/ipfs/QmYykQW876J2pa1kL935TTifAEnyFqF6inUwhMJqJz3piA) | Share posts or comments as images. With the intention of supporting QR codes and *Engravings* in the future. |

| Search    | |
| :-------- | -------: |
| ![Image](https://gateway.ipfs.io/ipfs/QmV6HpHVvRaEeJRBJAtQZC2mefBEKw4Lgj3TJXBtqsxQP4) | Either search all, a specific subcategory with sort support. View expanded contents within the view, interacting with content as normal. |

| Profile    | |
| :-------- | -------: |
| ![Image](https://gateway.ipfs.io/ipfs/QmYgVViPqKpYJttMeK32C5uLQy88HWqRJRjLAxjVU48tpL) | Dynamic threads, despite viewing context. Swipe to reply to comments or tap the more button, to modify, remove, block, etc.  |
| ![Image](https://gateway.ipfs.io/ipfs/QmbcEyh6qHqJt3sfEF2CL8Xjhjbcd2wLXUd27GNro7pgCD) | Deleting and restoring with toast reactions. |
| ![Image](https://gateway.ipfs.io/ipfs/Qmf1NCciupPPGFsqnza2F9QMVE8fSYUyqDqMcTT7pdiozw) | Switch accounts, view their profiles, and their scores. |

| Embedded Webview    | |
| :-------- | -------: |
| ![Image](https://gateway.ipfs.io/ipfs/QmV7Wo17wdB2vueyYiXeDxeLX2LLd8tS1JKgrFrAhcQ1M2) | Custom JS insertion supported, customizing how webpages are viewed via direct user input is a possibility. |

| Light Mode    | |
| :-------- | -------: |
| ![Image](https://gateway.ipfs.io/ipfs/QmUtjSKkYmvJ1erK4eQpwuMpqLPBHZWTUGH2V658Td3u6W) | Light mode and Dark mode supported. Refer to the color group in `Assets` to define your own preferences for each. |




## Contributing 

Loom uses [Granite](https://github.com/pexavc/Granite) as a backing for components and services. The Components folder in this repo serves as a good example for many future components that may be needed. Any suggestions on Granite or other component layouts as a whole is greatly appreciated. Always feel free to open a PR and/or Issue.

An interactive websites to generate boilerplate components using a GUI to define styling and needed state properties is in the works! This will allow you to simply download the generated component and drag into XCode for immediate use.

### Why Granite?

Mostly because of *Relays* and project organization. I'd say testing too, but once I get around towards writing the unit tests, I'd feel more confident in sharing the strengths then. These work like @Observables/@AppStorage, but are more flexible in initializations and caching data. The ability to simply declare relays in any `View` or `GraniteComponent` allows for a more effective iterative process and cleaner context passing throughout the application.

```swift
@Relay var configService: ConfigService
```

## Swift Packages

- [Granite](https://github.com/pexavc/Granite)
- [MarqueKit](https://github.com/pexavc/marquekit)
- [MarbleKit](https://github.com/pexavc/marblekit)
- [ModerationKit](https://github.com/pexavc/moderationkit)
- [FederationKit](https://github.com/neatia/federationkit)
- [IPFSKit](https://github.com/pexavc/ipfskit)
- [NukeUI](https://github.com/kean/nuke) Thanks to [@kean](https://github.com/kean)
- [MarkdownView](https://github.com/pexavc/MarkdownView) Thanks to [@LiYanan2004](https://github.com/LiYanan2004)
- [KeyboardToolbar](https://github.com/simonbs/KeyboardToolbar) Thanks to [@simonbs](https://github.com/simonbs)

### Contact

- [Twitter @pexavc](https://twitter.com/pexavc)
