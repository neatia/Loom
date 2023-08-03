//
//  GlobalStyle.swift
//  * stoic (iOS)
//
//  Created by PEXAVC on 12/20/20.
//

import Foundation
import SwiftUI

public struct Brand {
    public struct Colors {
        public static var marble: Color = .init(hex: "#A19A8E")
        public static var marbleV2: Color = .init(hex: "#CFCAC1")
        public static var grey: Color = .init(hex: "#808080")
        public static var greyV2: Color = .init(hex: "#D8D8D8")
        public static var white: Color = .init(hex: "#FFFFFF")
        public static var green: Color = .init(hex: "#39FF14")
        public static var red: Color = .init(hex: "#D90000")
        public static var redBurn: Color = .init(hex: "#D02F0E")
        public static var blue: Color = .init(hex: "#1FC2C4")
        public static var babyBlue: Color = .init(hex: "#89CFF0")
        public static var purple: Color = .init(hex: "#EC6CFF")
        public static var yellow: Color = .init(hex: "#FFCD00")
        public static var salmon: Color = .init(hex: "#FFB150")
        public static var black: Color = .init(hex: "#121212")
        public static var orange: Color = .init(hex: "#BC8C37")
        public static var brown: Color = .init(hex: "#A8874C")
    }
    
    public struct Gradients {
        public static var marbleGradient: LinearGradient {
            return .init(
                gradient: .init(
                    colors: [Color(hex: "#CFCAC1"),
                             Color(hex: "#A19A8E")]),
                startPoint: .init(x: 0.0, y: 0.0),
                endPoint: .init(x: 0.48, y: 0.48))
        }
    }
    
    public struct Padding {
        public static var layer5: CGFloat = 24
        public static var layer4: CGFloat = 16
        public static var layer3: CGFloat = 12
        public static var layer2: CGFloat = 8
        public static var layer1: CGFloat = 4
    }
}

public extension CGFloat {
    static var layer6: CGFloat { 32 }
    static var layer5: CGFloat { 24 }
    static var layer4: CGFloat { 16 }
    static var layer3: CGFloat { 12 }
    static var layer2: CGFloat { 8 }
    static var layer1: CGFloat { 4 }
}
