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
        case deleted
        case unknown
        case blocked
        case reported
    }
    
    var kind: Kind
    
    var isComment: Bool
    
    var height: CGFloat {
        isComment ? 100 : 200
    }
    
    var titleFont: Font {
        isComment ? .title3 : .title
    }
    
    var titleFontAlt: Font {
        isComment ? .title : .largeTitle
    }
    
    var bodyFont: Font {
        isComment ? .footnote : .subheadline
    }
    
    var body: some View {
        VStack {
            AppBlurView(size: .init(width: 0, height: height),
                        cornerRadius: 8) {
                switch kind {
                case .nsfw:
                    VStack(spacing: .layer4) {
                        Image(systemName: "eye.slash.fill")
                            .font(titleFont)
                            .foregroundColor(.foreground)
                        
                        Text("CENSOR_NSFW")
                            .font(bodyFont.bold())
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, .layer3)
                            .foregroundColor(.foreground)
                    }
                    .frame(maxWidth: .infinity)
                case .bot:
                    VStack(spacing: .layer4) {
                        Text("🤖")
                            .font(titleFontAlt)
                        Text("CENSOR_BOT")
                            .font(bodyFont.bold())
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, .layer3)
                            .foregroundColor(.foreground)
                    }
                    .frame(maxWidth: .infinity)
                case .removed:
                    VStack(spacing: .layer4) {
                        Image(systemName: "exclamationmark.octagon")
                            .font(titleFont)
                            .foregroundColor(.foreground)
                        
                        //TODO: localize
                        Text("Removed by moderators")
                            .font(bodyFont.bold())
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, .layer3)
                            .foregroundColor(.foreground)
                        
                    }
                    .frame(maxWidth: .infinity)
                case .deleted:
                    VStack(spacing: .layer4) {
                        Image(systemName: "trash")
                            .font(titleFont)
                            .foregroundColor(.foreground)
                        
                        Text("MISC_REMOVED")
                            .font(bodyFont.bold())
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, .layer3)
                            .foregroundColor(.foreground)
                        
                    }
                    .frame(maxWidth: .infinity)
                case .blocked:
                    VStack(spacing: .layer4) {
                        Image(systemName: "exclamationmark.shield")
                            .font(titleFont)
                            .foregroundColor(.foreground)
                        
                        Text("TITLE_BLOCKED")
                            .font(bodyFont.bold())
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, .layer3)
                            .foregroundColor(.foreground)
                        
                    }
                    .frame(maxWidth: .infinity)
                case .reported:
                    VStack(spacing: .layer4) {
                        Image(systemName: "exclamationmark.octagon")
                            .font(titleFont)
                            .foregroundColor(.foreground)
                        
                        Text("MISC_REPORTED")
                            .font(bodyFont.bold())
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
            .frame(height: height)
        }
    }
}

extension View {
    func censor(_ condition: Bool,
                kind: CensorView.Kind = .nsfw,
                paddingTop: CGFloat = .layer2,
                isComment: Bool = false) -> some View {
        return Group {
            if condition {
                CensorView(kind: kind, isComment: isComment)
                    .frame(maxWidth: Device.isExpandedLayout ? ContainerConfig.iPhoneScreenWidth : nil)
                    .padding(.top, paddingTop)
            } else {
                self
            }
        }
    }
    
    func censorAutoFit(_ condition: Bool,
                       kind: CensorView.Kind = .nsfw) -> some View {
        return Group {
            if condition {
                //TODO: Other types
                ZStack {
                    Color.secondaryBackground
                    switch kind {
                    case .bot:
                        Text("🤖")
                            .font(.title)
                    default:
                        Image(systemName: "eye.slash.fill")
                            .font(.title3)
                            .foregroundColor(.foreground)
                    }
                }
            } else {
                self
            }
        }
    }
}
