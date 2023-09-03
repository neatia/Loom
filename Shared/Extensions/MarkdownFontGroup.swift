//
//  MarkdownFontGroup.swift
//  Loom (macOS)
//
//  Created by PEXAVC on 8/19/23.
//

import Foundation
import MarkdownView
import SwiftUI

extension MarkdownFontGroup {
    public var h1: Font { Font.largeTitle.bold() }
    public var h2: Font { Font.title.bold() }
    public var h3: Font { Font.title2.bold() }
    public var h4: Font { Font.title3.bold() }
    public var h5: Font { Font.headline.bold() }
    public var h6: Font { Font.headline.weight(.regular) }
}

public struct PostDisplayFontGroup: MarkdownFontGroup {
//    // Headings
//    var h1: Font { get }
//    var h2: Font { get }
//    var h3: Font { get }
//    var h4: Font { get }
//    var h5: Font { get }
//    var h6: Font { get }
//
//    // Normal text
    
    public let body: Font
    
    public var unorderedList: Font {
        .headline
    }
//    // Blocks
//    var codeBlock: Font { get }
//    var blockQuote: Font { get }
//
//    // Tables
//    var tableHeader: Font { get }
//    var tableBody: Font { get }
    
    init(_ body: Font = .subheadline) {
        self.body = body
    }
}

extension MarkdownFontGroup where Self == DefaultFontGroup {
    static var postDisplay: MarkdownFontGroup {
        PostDisplayFontGroup()
    }
}

public struct CommentFontGroup: MarkdownFontGroup {
    public var body: Font {
        .subheadline
    }
    
    public var unorderedList: Font {
        .headline
    }
}
