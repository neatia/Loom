//
//  StandardToolbarView.swift
//  Loom
//
//  Created by PEXAVC on 8/14/23.
//

import Foundation
import Granite
import GraniteUI
import SwiftUI

struct StandardToolbarView: View {
    @GraniteAction<Void> var search
    
    var body: some View {
        Group {
            Spacer()
            
            Button {
                GraniteHaptic.light.invoke()
                
                #if os(iOS)
                UIApplication.hideKeyboard()
                #endif
            } label : {
                if #available(macOS 13.0, iOS 16.0, *) {
                    Image(systemName: "keyboard.chevron.compact.down.fill")
                        .font(.headline)
                } else {
                    Image(systemName: "chevron.down")
                        .font(.headline)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
    }
}
