//
//  Feed.Horizontal.swift
//  Lemur
//
//  Created by PEXAVC on 7/29/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import LemmyKit

extension Feed {
    var minFrameWidth: CGFloat {
        200 + ContainerConfig.iPhoneScreenWidth + 500 + 4
    }
    
    var minFrameWidthClosed: CGFloat {
        200 + ContainerConfig.iPhoneScreenWidth + 4
    }
    
    //Primarily for macOS
    var horizontalLayout: some View {
        HStack(spacing: 0) {
            CommunityPickerView(modal: false,
                                verticalPadding: 0,
                                sidebar: true)
            .attach({ communityView in
                DispatchQueue.main.async {
                    self.config._state.feedCommunityContext.wrappedValue = .viewCommunityView(communityView)
                }
            }, at: \.pickedCommunity)
            .frame(width: 240)
            Divider()
            verticalLayout
                .frame(minWidth: 480, maxWidth: config._state.wrappedValue.closeFeedDisplayView ? nil : 480)
            if config._state.wrappedValue.closeFeedDisplayView == false {
                switch config._state.wrappedValue.feedContext {
                case .viewPost(let model):
                    Divider()
                    PostDisplayView(model: model,
                                    isFrontPage: true)
                    .id(model.id)
                default:
                    Spacer()
                }
            }
            
            if config._state.wrappedValue.feedContext != .idle {
                Divider()
                
                Button {
                    config._state.wrappedValue.closeFeedDisplayView.toggle()
                } label: {
                    
                    closeView
                }.buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    var closeView: some View {
        ZStack {
            Color.background
            
            VStack {
                Spacer()
                
                HStack(spacing: 0) {
                    Image(systemName: "chevron.\(config._state.wrappedValue.closeFeedDisplayView ? "right" : "left").2")
                        .font(.title3)
                }
                
                Spacer()
            }
        }
        .frame(maxHeight: .infinity)
        .frame(width: 36)
    }
}
