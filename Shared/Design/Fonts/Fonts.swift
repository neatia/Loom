//
//  Fonts.swift
//  * stoic (iOS)
//
//  Created by PEXAVC on 12/20/20.
//

import Foundation
import SwiftUI

public struct Fonts {
    public static func live(_ size: FontSize, _ weight: FontWeight) -> Font {
        return Font.custom(
            "\(FontType.menlo.rawValue)-\(weight.rawValue)",
            size: size.value,
            relativeTo: size.textStyle)
    }
    
    public enum FontSize: String {
        case largeTitle
        case title
        case title2
        case title3
        case headline
        case body
        case callout
        case subheadline
        case footnote
        case caption
        case caption2
        
        var value: CGFloat {
            switch self {
            case .largeTitle:
                return 34
            case .title:
                return 28
            case .title2:
                return 22
            case .title3:
                return 20
            case .headline:
                return 16
            case .body:
                return 17
            case .callout:
                return 16
            case .subheadline:
                return 14
            case .footnote:
                return 12
            case .caption:
                return 12
            case .caption2:
                return 11
            }
        }
        
        var textStyle: Font.TextStyle {
            switch self {
            case .largeTitle:
                return .largeTitle
            case .title:
                return .title
            case .title2:
                return .title2
            case .title3:
                return .title3
            case .headline:
                return .headline
            case .body:
                return .body
            case .callout:
                return .callout
            case .subheadline:
                return .subheadline
            case .footnote:
                return .footnote
            case .caption:
                return .caption
            case .caption2:
                return .caption2
            }
        }
    }
    
    public enum FontWeight: String {
        case bold = "Bold"
        case boldItalic = "BoldItalic"
        case regular = "Regular"
        case italic = "Italic"
    }
    
    public enum FontType: String {
        case menlo = "Menlo"
    }
}

extension Font {
    var smaller: Font {
        switch self {
        case .largeTitle:
            return .title
        case .title:
            return .title2
        case .title2:
            return .title3
        case .title3:
            return .headline
        case .headline:
            return .subheadline
        case .subheadline:
            return .callout
        case .callout:
            return .footnote
        case .footnote:
            return .caption
        default:
            return self
        }
    }
}
