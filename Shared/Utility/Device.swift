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
    
    static var hasNotch: Bool {
        guard Device.isIPhone else { return false}
        
        #if os(iOS)
        guard let windowScene = UIApplication.shared
            .connectedScenes
            .first as? UIWindowScene else {
            LoomLog("Could not get connected scene", level: .error)
            return false
        }
        
        guard let keyWindow = windowScene.keyWindow else {
            LoomLog("Could not get keyWindow", level: .error)
            return false
        }
        
        if UIDevice.current.orientation.isPortrait || windowScene.interfaceOrientation.isPortrait  {
            return keyWindow.safeAreaInsets.bottom > 0
        } else {
            return keyWindow.safeAreaInsets.left > 0 || keyWindow.safeAreaInsets.right > 0
        }
        #else
        return false
        #endif
    }
    
    static var appVersion: String? {
        if let releaseVersion = Bundle.main.releaseVersionNumber,
           let buildVersion = Bundle.main.buildVersionNumber {
            
            return releaseVersion + buildVersion
        } else {
            return nil
        }
    }
    
    static var statusBarHeight:  CGFloat {
        #if os(iOS)
        guard let windowScene = UIApplication.shared
            .connectedScenes
            .first as? UIWindowScene else {
            LoomLog("Could not get connected scene", level: .error)
            return 0
        }
        
        return windowScene.statusBarManager?.statusBarFrame.height ?? 0
        
        #else
        return 0
        #endif
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
