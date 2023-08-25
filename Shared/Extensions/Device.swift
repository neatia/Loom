//
//  Device.swift
//  Stoic
//
//  Created by PEXAVC on 7/5/23.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

struct Device {
    static var isMacOS: Bool {
        #if os(macOS)
        return true
        #else
        return false
        #endif
    }
    
    static var isiPad: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad
        #else
        return false
        #endif
    }
    
    static var isIPhone: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom != .pad
        #else
        return false
        #endif
    }
    
    static var isExpandedLayout: Bool {
        isMacOS || isiPad
    }
    
    static var appVersion: String? {
        if let releaseVersion = Bundle.main.releaseVersionNumber,
           let buildVersion = Bundle.main.buildVersionNumber {
            
            return releaseVersion + buildVersion
        } else {
            return nil
        }
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        infoDictionary?["CFBundleVersion"] as? String
    }
}
