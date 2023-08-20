//
//  ShareModal.swift
//  Loom
//
//  Created by PEXAVC on 8/20/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import LemmyKit
import UIKit
import MarqueKit

public struct ShareModal<Content: View>: View {
    
    @State var isScreenshotting: Bool = false
    
    var urlString: String? = nil
    var content: () -> Content
    init(urlString: String? = nil,
         @ViewBuilder content: @escaping () -> Content) {
        self.urlString = urlString
        self.content = content
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                ScreenshotView($isScreenshotting,
                               encodeMessage: urlString) {
                    content()
                }
                .fixedSize(horizontal: false, vertical: true)
                .cornerRadius(8)
            }
            
            Spacer()
            
            HStack(spacing: .layer3) {
                Spacer()
                
                Button {
                    GraniteHaptic.light.invoke()
                    isScreenshotting = true
                } label: {
                    Image(systemName: "photo")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                
                if let urlString {
                    Button {
                        GraniteHaptic.light.invoke()
                        ModalService.share(urlString: urlString)
                    } label: {
                        Image(systemName: "link")
                            .font(.title2)
                            .scaleEffect(x: -1, y: 1)
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
            }
            
            Spacer()
        }
    }
}
