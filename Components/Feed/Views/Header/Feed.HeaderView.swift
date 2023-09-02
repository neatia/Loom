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

/*
 All this header view logic can definitely be cleanly
 reorganized... (with related files)
 
 This is a product of constant nitpicking on 4 form factors
 - iphone
 - iphone w/ community banner
 - ipad/macos
 - ipad/macos w/ community banner
 */

extension Feed {
    var headerView: some View {
        VStack(alignment: .leading, spacing: 0) {
            if Device.isExpandedLayout {
                accountExpandedMenuView
                    .padding(.horizontal, Device.isExpandedLayout ? .layer3 : .layer4)
            } else if isCommunity {
                HStack(spacing: 0) {
                    navigationStyle
                        .leadingItem
                        .frame(width: 24, height: 24)
                        .readabilityIf(hasCommunityBanner, cornerRadius: 4, padding: 6)
                        .onTapGesture {
                            GraniteHaptic.light.invoke()
                            router.pop()
                        }
                    
                    Spacer()
                    
                    //readability handled inside
                    communityInfoMenuView
                        .readabilityIf(hasCommunityBanner, cornerRadius: 4, padding: 6)
                }
                .padding(.horizontal, .layer4)
                .padding(.top, .layer3)
                .padding(.bottom, hasCommunityBanner == false ? .layer2 : 0)
            }
            
            titleBarView
                .padding(.horizontal, Device.isExpandedLayout ? .layer3 : .layer4)
            
            HStack(spacing: 0) {
                if Device.isIPhone && state.community == nil {
                    Button {
                        GraniteHaptic.light.invoke()
                        _state.isShowing.wrappedValue = true
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.title3)
                            .rotationEffect(.degrees(90))
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, .layer3)
                    .padding(.leading, 2)//nitpick
                }
                
                headerMenuView
                
                Spacer()
                
                if pager.isFetching || pager.isEmpty {
                    pagerIndicatorView
                }
                
                if Device.isExpandedLayout == false {
                    AccountView()
                        .attach({
                            GraniteHaptic.light.invoke()
                            ModalService.shared.presentSheet {
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
            .padding(.trailing, Device.isExpandedLayout ? .layer3 : .layer4)
            .padding(.leading, Device.isIPhone && state.community == nil ? .layer2 : (Device.isExpandedLayout ? .layer3 : .layer4))
            .padding(.bottom, .layer2)
            
            Divider()
        }
        .padding(.top, headerPaddingTop)
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
    
    var headerPaddingTop: CGFloat {
        #if os(iOS)
        if Device.isIPhone {
            return UIApplication.shared.windowSafeAreaInsets.top
        } else {
            return 0
        }
        #else
        return 0
        #endif
    }
    
    var pagerIndicatorView: some View {
        Group {
            if pager.fetchMoreTimedOut || (pager.isEmpty && pager.isFetching == false) {
                Button {
                    GraniteHaptic.light.invoke()
                    pager.reset()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.headline.bold())
                        .offset(y: (hasCommunityBanner == false) ? (Device.isExpandedLayout ? -3 : -1) : 0)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, hasCommunityBanner ? 6 : 0)
                .padding(.vertical, hasCommunityBanner ? 4 : 0)
                .backgroundIf(hasCommunityBanner) {
                    Color.background.opacity(0.75)
                        .cornerRadius(4)
                }
                .padding(.trailing, Device.isExpandedLayout ? 0 : .layer3)
            } else {
                if Device.isExpandedLayout {
                    StandardProgressView()
                        .padding(.horizontal, hasCommunityBanner ? 4 : 0)
                        .padding(.vertical, hasCommunityBanner ? 4 : 0)
                        .backgroundIf(hasCommunityBanner) {
                            Color.background.opacity(0.75)
                                .cornerRadius(6)
                        }
                        .offset(x: .layer1)
                } else {
                    StandardProgressView()
                        .padding(.horizontal, hasCommunityBanner ? 6 : 0)
                        .padding(.vertical, hasCommunityBanner ? 4 : 0)
                        .backgroundIf(hasCommunityBanner) {
                            Color.background.opacity(0.75)
                                .cornerRadius(6)
                        }
                        .padding(.trailing, .layer3)
                }
            }
        }
    }
}
