<p align="center"><img src="https://gateway.ipfs.io/ipfs/QmUR5vx55UVCeo1gWSk5zmoc5hKh4XXf1mrFrU3pBQpy2r" height="120px" /></p>

<h1 align="center">Loom (iOS & macOS) Beta</h1>

<p align="center"><img src="https://gateway.ipfs.io/ipfs/QmZ46tDJLuGcnggQSWUwi3tKUdTq5upsX8S1YNeevT6jqx" width="90%" /></p>

<a href="https://testflight.apple.com/join/owwIagmV"><h2 align="center">Testflight (iOS)</h2></a>
<p align="center">https://testflight.apple.com/join/owwIagmV</p>


<p align="center">An app with "Threads" that does not collect your data. Providing everyone with a premium experience when interacting with federated link aggregators. Meanwhile, providing view libraries and solutions for others to implement their own interpretations.</p>

## Requirements
![Swift Compatibility](https://img.shields.io/badge/Swift-5.9%20%7C%205.8%20%7C%205.7-orange?logo=swift)
![Platform Compatibility](https://img.shields.io/badge/Platform-iOS%20%7C%20macOS-blue)
[![License](https://img.shields.io/badge/License-GPL_3.0--Clause-orange.svg)](https://opensource.org/license/gpl-3-0/)

> My local environment: Xcode 14.2 or later // macOS (Intel) 12.6 or later // iOS 15.4 or later

## Disclaimers
- Due to the nature of possible state schemas being changed. Saved data such as account information or bookmarks may be removed in future release versions (or not at all).
- Keychain access warning. Keychain is only used for STORING your passwords and nothing else.

## Features
- Translated into 28 languages (MTL)
- Bookmarks are locally stored for offline viewing
- IPFS Content generation (Add your own config, gateway, etc)
- Login, Create Posts, Comments, Interact, update profiles as normal
- *Engravings* (Coming Soon / iOS only), protect your OC against unwarranted reposts
- *Advanced Search* (Coming Soon), turn any thread/post into a searchable interface powered by [BERT](https://arxiv.org/abs/1810.04805)
- *and much more…*

### [Changelog // Developer updates](https://lemmy.world/post/2779700)

## Contributing 

Loom uses [Granite](https://github.com/pexavc/Granite) as a backing for components and services. The Components folder in this repo serves as a good example for many future components that may be needed. Any suggestions on Granite or other component layouts as a whole is greatly appreciated. Always feel free to open a PR and/or Issue.

### Why Granite?

Mostly because of *Relays*. These work like environment objects, but are more flexible in initializations. No need to passdown directly. The ability to simply declare relays in any `View` or `GraniteComponent` allows for a more effective iterative process and cleaner context passing throughout the application.

```swift
@Relay var configService: ConfigService
```

## Swift Packages

- [Granite](https://github.com/pexavc/Granite)
- [LemmyKit](https://github.com/pexavc/lemmykit)
- [IPFSKit](https://github.com/pexavc/ipfskit)
- [NukeUI](https://github.com/kean/nuke) Thanks to [@kean](https://github.com/kean/nuke)
- [MarkdownView](https://github.com/pexavc/MarkdownView) Thanks to [@LiYanan2004](https://github.com/LiYanan2004)

## Discussion

In an attempt to build a community around Loom as well, feel free to explore the places below!

- [@lemmy.world](https://lemmy.world/c/loom)
- Matrix Spaces: `!cYiAYEKIMRaZcuuudA:matrix.org`

### Contact

- [Twitter @pexavc](https://twitter.com/pexavc)
- Discord: @pexavc
- Matrix: @pexavc:matrix.org


### Support

The goal is to eventually have this be community driven. Until then, if you like my work and think these contributions are truly beneficial, feel free to support future updates and similar endeavors! 

**ETH:** 0x9223F7F36cA5F052044fe1edE65E23C9F7dEB655 

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/pexavc)
