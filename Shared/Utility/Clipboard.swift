//
//  Clipboard.swift
//  Loom
//
//  Created by PEXAVC on 9/3/23.
//

import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif


struct Clipboard {
    static var hasContents: Bool {
        contents != nil
    }
    
    static var contents: String? {
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        
        var clipboardItems: [String] = []
        for element in pasteboard.pasteboardItems! {
            if let str = element.string(forType: NSPasteboard.PasteboardType(rawValue: "public.utf8-plain-text")) {
                clipboardItems.append(str)
            }
        }
        
        return clipboardItems[0]
        #else
        return UIPasteboard.general.string
        #endif
    }
    
    static func copyToClipboard(_ value: String) {
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        pasteboard.setString(value, forType: .string)
        #else
        UIPasteboard.general.string = value
        #endif
    }
}
