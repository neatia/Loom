//
//  FeedExtendedView.swift
//  Lemur
//
//  Created by PEXAVC on 8/5/23.
//

import Foundation
import Granite
import SwiftUI


struct FeedExtendedView: View {
    @Relay var layout: LayoutService
    
    init() {
        //layout.preload()
    }
    
    var body: some View {
        Group {
            if layout.state.feedContext == .idle {
                EmptyView()
            } else {
                mainView
            }
        }
    }
    var mainView: some View {
        HStack(spacing: 0){
            
            if layout.state.closeFeedDisplayView == false {
                switch layout.state.feedContext {
                case .viewPost(let model):
                    Divider()
                    PostDisplayView(model: model,
                                    isFrontPage: true)
                    .id(model.id)
                default:
                    Spacer()
                }
            }
            Divider()
            
            Button {
                layout._state.closeFeedDisplayView.wrappedValue.toggle()
            } label: {
                
                closeView
            }.buttonStyle(PlainButtonStyle())
        }
    }
    
    var closeView: some View {
        ZStack {
            Color.background
            
            VStack {
                Spacer()
                
                HStack(spacing: 0) {
                    Image(systemName: "chevron.\(layout.state.closeFeedDisplayView ? "right" : "left").2")
                        .font(.title3)
                }
                
                Spacer()
            }
        }
        .frame(maxHeight: .infinity)
        .frame(width: 36)
    }
}
