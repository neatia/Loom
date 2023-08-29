//
//  DebugOverlay.swift
//  Loom
//
//  Created by PEXAVC on 8/27/23.
//

import Foundation
import SwiftUI

extension View {
    func debugContextOverlay() -> some View {
        Group {
            if Debug.overlayEnabled {
                self.overlay(DebugContextView())
            } else {
                self
            }
        }
    }
}

struct DebugContextView: View {
    @Environment(\.contentContext) var context
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    if context.isComment {
                        Text("Comment")
                    } else {
                        Text("Post")
                    }
                    
                    Text("\(context.feedStyle.rawValue)")
                    
                }
                .frame(width: 150, height: 150)
                .background(
                    RoundedRectangle(
                        cornerRadius: 8)
                    .foregroundColor(
                        Color
                            .background
                            .opacity(0.8)
                    )
                )
                
                
                Spacer()
            }
            Spacer()
        }
        .allowsHitTesting(false)
    }
}
