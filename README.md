<p align="center"><img src="https://gateway.ipfs.io/ipfs/QmUR5vx55UVCeo1gWSk5zmoc5hKh4XXf1mrFrU3pBQpy2r" height="120px" /></p>

<h1 align="center">Loom (iOS & macOS) Beta</h1>

<p align="center"><img src="https://gateway.ipfs.io/ipfs/QmZ46tDJLuGcnggQSWUwi3tKUdTq5upsX8S1YNeevT6jqx" width="90%" /></p>

<a href="https://testflight.apple.com/join/owwIagmV"><h2 align="center">Testflight (iOS)</h2></a>
<p align="center">https://testflight.apple.com/join/owwIagmV</p>


<p align="center">Aggregating aggregation. Providing everyone with a premium experience when interacting with federated servers. Meanwhile, providing view libraries and solutions for others to implement their own interpretations in the Apple ecosystem.</p>

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

## Component Previews

> WIP previews of major components

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

| Bookmark Syncing    | |
| :-------- | -------: |
| <img src="https://gateway.ipfs.io/ipfs/Qmakr2HyJnXf87tseVhbjgqiKuqRoj3rUo79TK8DoKjwTg" width="50%"/> | All your saved posts and comments can be switched between accounts in a dedicated component.   |

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
| ![Image](https://gateway.ipfs.io/ipfs/QmV7Wo17wdB2vueyYiXeDxeLX2LLd8tS1JKgrFrAhcQ1M2) | Embedded Webview to customize the viewing experience. Custom JS insertion supported, customizing how webpages are viewed via direct user input is a possibility. |

| Light Mode    | |
| :-------- | -------: |
| ![Image](https://gateway.ipfs.io/ipfs/QmUtjSKkYmvJ1erK4eQpwuMpqLPBHZWTUGH2V658Td3u6W) | Light mode and Dark mode supported. Refer to the color group in `Assets` to define preferences. |




## Contributing 

Loom uses [Granite](https://github.com/pexavc/Granite) as a backing for components and services. The Components folder in this repo serves as a good example for many future components that may be needed. Any suggestions on Granite or other component layouts as a whole is greatly appreciated. Always feel free to open a PR and/or Issue.

### Why Granite?

Mostly because of *Relays*. These work like environment objects, but are more flexible in initializations. No need to passdown directly. The ability to simply declare relays in any `View` or `GraniteComponent` allows for a more effective iterative process and cleaner context passing throughout the application.

```swift
@Relay var configService: ConfigService
```

## Swift Packages

- [Granite](https://github.com/pexavc/Granite)
- [MarqueKit](https://github.com/pexavc/marquekit)
- [MarbleKit](https://github.com/pexavc/marblekit)
- [LemmyKit](https://github.com/pexavc/lemmykit)
- [IPFSKit](https://github.com/pexavc/ipfskit)
- [NukeUI](https://github.com/kean/nuke) Thanks to [@kean](https://github.com/kean/nuke)
- [MarkdownView](https://github.com/pexavc/MarkdownView) Thanks to [@LiYanan2004](https://github.com/LiYanan2004)
- [KeyboardToolbar](https://github.com/simonbs/KeyboardToolbar) Thanks to [@simonbs](https://github.com/simonbs)

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
