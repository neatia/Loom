//
//  ContainerConfig.swift
//  * stoic
//
//  Created by PEXAVC on 12/31/20.
//

import Foundation
import SwiftUI
import Granite

#if os(iOS)
import UIKit
#endif

public struct ContainerConfig: GraniteModel {
    public enum PageType: GraniteModel {
        case home
        case floor
        case intro
        case discuss
        case special
    }
    
    let kind: PageType
    
    static var none: ContainerConfig {
        return .init(kind: .home)
    }
}

extension ContainerConfig {
    public static var isIPad: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad
        #else
        return false
        #endif
    }
    
    public static var isIPhone: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .phone
        #else
        return false
        #endif
    }
    
    public static var iPhoneScreenWidth: CGFloat {
        #if canImport(UIKit)
        return UIScreen.main.bounds.width
        #else
        return 360
        #endif
    }
    
    public static var iPhoneScreenHeight: CGFloat {
        #if canImport(UIKit)
        return UIScreen.main.bounds.height - (ContainerStyle.ControlBar.iPhone.maxHeight + .layer2)
        #else
        return 812
        #endif
    }
}
public struct ContainerStyle {
    static var idealWidth: CGFloat = 375
    static var idealHeight: CGFloat = 420
    static var minWidth: CGFloat = 320
    static var minHeight: CGFloat = 120
    static var maxWidth: CGFloat = 500
    static var maxHeight: CGFloat = 400
    
    public struct ControlBar {
        public struct iPhone {
            static var minHeight: CGFloat = 36
            static var maxHeight: CGFloat = 42
        }
        
        public struct Default {
            static var minWidth: CGFloat = 100
            static var maxWidth: CGFloat = 150
        }
    }
    
    public struct Floor {
        public struct iPhone {
            static var minHeight: CGFloat = 36
            static var maxHeight: CGFloat = 42
        }
        
        public struct Default {
            static var minWidth: CGFloat = 100
            static var maxWidth: CGFloat = 150
        }
    }
}
