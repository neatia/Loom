//
//  CensorView.swift
//  Loom
//
//  Created by PEXAVC on 7/26/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI

struct CensorView: View {
    enum Kind {
        case nsfw
        case bot
        case removed
        case unknown
        case blocked
        case reported
    }
    
    var kind: Kind
    
    var body: some View {
        VStack {
            AppBlurView(size: .init(width: 0, height: 200)) {
                switch kind {
                case .nsfw:
                    VStack(spacing: .layer4) {
                        Image(systemName: "eye.slash.fill")
                            .font(.title)
                            .foregroundColor(.foreground)
                        
                        Text("CENSOR_NSFW")
                            .font(.subheadline.bold())
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, .layer3)
                            .foregroundColor(.foreground)
                    }
                    .frame(maxWidth: .infinity)
                case .bot:
                    VStack(spacing: .layer4) {
                        Text("🤖")
                            .font(.largeTitle)
                        Text("CENSOR_BOT")
                            .font(.subheadline.bold())
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, .layer3)
                            .foregroundColor(.foreground)
                    }
                    .frame(maxWidth: .infinity)
                case .removed:
                    VStack(spacing: .layer4) {
                        Image(systemName: "trash")
                            .font(.title)
                            .foregroundColor(.foreground)
                        
                        Text("MISC_REMOVED")
                            .font(.subheadline.bold())
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, .layer3)
                            .foregroundColor(.foreground)
                        
                    }
                    .frame(maxWidth: .infinity)
                case .blocked:
                    VStack(spacing: .layer4) {
                        Image(systemName: "exclamationmark.shield")
                            .font(.title)
                            .foregroundColor(.foreground)
                        
                        Text("TITLE_BLOCKED")
                            .font(.subheadline.bold())
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, .layer3)
                            .foregroundColor(.foreground)
                        
                    }
                    .frame(maxWidth: .infinity)
                case .reported:
                    VStack(spacing: .layer4) {
                        Image(systemName: "exclamationmark.octagon")
                            .font(.title)
                            .foregroundColor(.foreground)
                        
                        Text("MISC_REPORTED")
                            .font(.subheadline.bold())
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, .layer3)
                            .foregroundColor(.foreground)
                        
                    }
                    .frame(maxWidth: .infinity)
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

extension View {
    func censor(_ condition: Bool, kind: CensorView.Kind = .nsfw) -> some View {
        Group {
            if condition {
                CensorView(kind: kind)
                    .frame(height: 200)
                    .frame(maxWidth: Device.isMacOS ? 400 : nil)
            } else {
                self
            }
        }
    }
}
