//
//  Feed.HeaderFooter.swift
//  Loom (iOS)
//
//  Created by PEXAVC on 7/25/23.
//

import Foundation
import Granite
import GraniteUI
import SwiftUI
import NukeUI

extension Feed {
    var headerView: some View {
        VStack(alignment: .leading, spacing: 0) {
            if Device.isExpandedLayout {
                accountInfoExpandedView
                    .padding(.horizontal, Device.isExpandedLayout ? .layer3 : .layer4)
            }
            
            titleBarView
                .padding(.horizontal, Device.isExpandedLayout ? .layer3 : .layer4)
            
            HStack(spacing: 0) {
                headerMenuView
                
                Spacer()
                
                if pager.isFetching || pager.isEmpty {
                    pagerIndicatorView
                }
                
                if Device.isExpandedLayout == false {
                    AccountView()
                        .attach({
                            GraniteHaptic.light.invoke()
                            modal.presentSheet {
                                LoginView()
                            }
                        }, at: \.login)
                        .offset(y: hasCommunityBanner ? -1 : 0)
                        .padding(.horizontal, hasCommunityBanner ? 6 : 0)
                        .padding(.vertical, hasCommunityBanner ? 4 : 0)
                        .backgroundIf(hasCommunityBanner) {
                            Color.background.opacity(0.75)
                                .cornerRadius(4)
                        }
                        .padding(.bottom, hasCommunityBanner ? 0 : .layer1)
                }
            }
            .padding(.vertical, Device.isExpandedLayout ? 0 : .layer2)
            .padding(.horizontal, Device.isExpandedLayout ? .layer3 : .layer4)
            .padding(.bottom, .layer2)
            
            Divider()
        }
        .background(Color.background.overlayIf(state.community != nil) {
            if let banner = state.community?.banner,
               let url = URL(string: banner) {
                LazyImage(url: url) { state in
                    if let image = state.image {
                        image
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                            //menu + header + titlebar
                    } else {
                        Color.background
                    }
                }.allowsHitTesting(false)
            } else {
                EmptyView()
            }
        }
        .clipped())
    }
    
    var pagerIndicatorView: some View {
        Group {
            if pager.fetchMoreTimedOut || (pager.isEmpty && pager.isFetching == false) {
                Button {
                    GraniteHaptic.light.invoke()
                    pager.fetch(force: true)
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.headline.bold())
                        .offset(y: (hasCommunityBanner == false) ? (Device.isExpandedLayout ? -3 : -1) : 0)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, hasCommunityBanner ? 4 : 0)
                .padding(.vertical, hasCommunityBanner ? 4 : 0)
                .backgroundIf(hasCommunityBanner) {
                    Color.background.opacity(0.75)
                        .cornerRadius(4)
                }
                .padding(.trailing, Device.isExpandedLayout ? 0 : .layer2)
            } else {
                if Device.isExpandedLayout {
                    ProgressView()
                        .padding(.horizontal, hasCommunityBanner ? 4 : 0)
                        .padding(.vertical, hasCommunityBanner ? 4 : 0)
                        .backgroundIf(hasCommunityBanner) {
                            Color.background.opacity(0.75)
                                .cornerRadius(6)
                        }
                        .scaleEffect(Device.isMacOS ? 0.6 : 1.0)
                        .offset(x: .layer1)
                } else {
                    ProgressView()
                        .padding(.horizontal, hasCommunityBanner ? 4 : 0)
                        .padding(.vertical, hasCommunityBanner ? 4 : 0)
                        .backgroundIf(hasCommunityBanner) {
                            Color.background.opacity(0.75)
                                .cornerRadius(6)
                        }
                        .padding(.trailing, .layer2)
                }
            }
        }
    }
}
