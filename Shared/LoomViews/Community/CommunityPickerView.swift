//
//  CommunityPickerView.swift
//  Loom (iOS)
//
//  Created by PEXAVC on 7/21/23.
//

import Foundation
import LemmyKit
import SwiftUI
import Granite
import GraniteUI

struct CommunityPickerView: View {
    @GraniteAction<CommunityView> var pickedCommunity
    
    var modal: Bool = true
    var verticalPadding: CGFloat = .layer5
    var sidebar: Bool = false
    
    @State var bookmarksSelected: Bool = false
    
    @StateObject var subscribed: Pager<CommunityView> = .init(emptyText: "EMPTY_STATE_NO_COMMUNITIES")
    @StateObject var local: Pager<CommunityView> = .init(emptyText: "EMPTY_STATE_NO_COMMUNITIES")
    @StateObject var all: Pager<CommunityView> = .init(emptyText: "EMPTY_STATE_NO_COMMUNITIES")
    
    @State var page: ListingType = .subscribed
    
    func opacityFor(_ page: ListingType) -> CGFloat {
        return self.page == page ? 1.0 : 0.6
    }
    
    func fontFor(_ page: ListingType) -> Font {
        return self.page == page ? .title2.bold() : .title3.bold()
    }
    
    var currentPager: Pager<CommunityView> {
        switch page {
        case .all:
            return all
        case .local:
            return local
        case .subscribed:
            return subscribed
        }
    }
    
    var body: some View {
        VStack {
            if modal {
                Spacer()
            }
            
            ZStack {
#if os(iOS)
                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(Color.background)
                    .edgesIgnoringSafeArea(.all)
#endif
                VStack(spacing: 0) {
                    
                    if sidebar {
                        dropdownMenu
                    } else {
                        selectorView
                    }
                    
                    Divider()
                    
                    if bookmarksSelected {
                        Bookmark(showHeader: false)
                    } else {
                        PagerScrollView(CommunityView.self,
                                        hideDivider: true,
                                        useSimple: true) { communityView in
                            
                            if sidebar {
                                CommunitySidebarCardView(model: communityView,
                                                         fullWidth: true)
                                .onTapGesture {
                                    pickedCommunity.perform(communityView)
                                }
                                .padding(.leading, .layer3)
                                .padding(.trailing, .layer3)
                                .padding(.vertical, .layer3)
                            } else {
                                CommunityCardView(model: communityView,
                                                  fullWidth: true)
                                .routeIf(modal == false, style: .init(size: .init(width: 600, height: 500), styleMask: .resizable)) {
                                    Feed(communityView.community)
                                }
                                .onTapGesture {
                                    pickedCommunity.perform(communityView)
                                }
                                .padding(.leading, .layer3)
                                .padding(.trailing, .layer3)
                                .padding(.vertical, .layer3)
                            }
                            
                            
                            if communityView.id != currentPager.lastItem?.id {
                                Divider()
                                    .padding(.leading, .layer3)
                            }
                        }
                        .environmentObject(currentPager)
                    }
                    
                }
                .padding(.top, Device.isMacOS == false && modal ? .layer5 : 0)
            }
            .frame(maxHeight: modal ? 400 : nil)
        }
        .padding(.top, modal ? 0 : verticalPadding)
        .padding(.bottom, modal ? 0 : verticalPadding)
        .task {
            all.hook { page in
                await Lemmy.communities(.all, page: page)
            }
            local.hook { page in
                await Lemmy.communities(.local, page: page)
            }
            subscribed.hook { page in
                let communities = await Lemmy.communities(.subscribed, page: page)
                
                LoomLog("👥 fetched: \(communities.count) subscribed communities", level: .debug)
                
                return communities
            }
            currentPager.fetch()
        }
    }
}

extension CommunityPickerView {
    var dropdownMenu: some View {
        HStack(spacing: .layer4) {
            Menu {
                Button {
                    GraniteHaptic.light.invoke()
                    page = .all
                    all.fetch()
                } label: {
                    Text(ListingType.all.displayString)
                    Image(systemName: "arrow.down.right.circle")
                }
                Button {
                    GraniteHaptic.light.invoke()
                    page = .local
                    local.fetch()
                } label: {
                    Text(ListingType.local.displayString)
                    Image(systemName: "arrow.down.right.circle")
                }
                Button {
                    GraniteHaptic.light.invoke()
                    page = .subscribed
                    subscribed.fetch()
                } label: {
                    Text(ListingType.subscribed.displayString)
                    Image(systemName: "arrow.down.right.circle")
                }
            } label: {
                Text(page.displayString)
#if os(iOS)
                Image(systemName: "chevron.up.chevron.down")
#endif
            }
            .menuStyle(BorderlessButtonMenuStyle())
            .frame(maxWidth: Device.isMacOS ? 100 : nil)
            
            Button {
                GraniteHaptic.light.invoke()
                currentPager.fetch(force: true)
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.subheadline.bold())
                    .offset(y: -2)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            Button {
                bookmarksSelected.toggle()
            } label: {
                Image(systemName: "bookmark\(bookmarksSelected ? ".fill" : "")")
                    .renderingMode(.template)
                    .font(.headline.bold())
                    .frame(width: 20,
                           height: 20,
                           alignment: .center)
                    .contentShape(Rectangle())
                    .offset(y: -3)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(height: 36)
        .padding(.leading, .layer2)
        .padding(.trailing, .layer2)
        .padding(.vertical, .layer2)
        .foregroundColor(.foreground)
    }
    
    var selectorView: some View {
        
        HStack(spacing: .layer4) {
            
            Button {
                GraniteHaptic.light.invoke()
                page = .subscribed
                subscribed.fetch()
            } label: {
                VStack {
                    Spacer()
                    Text("LISTING_TYPE_SUBSCRIBED")
                        .font(fontFor(.subscribed))
                        .opacity(opacityFor(.subscribed))
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Button {
                GraniteHaptic.light.invoke()
                page = .local
                local.fetch()
            } label: {
                VStack {
                    Spacer()
                    Text("LISTING_TYPE_LOCAL")
                        .font(fontFor(.local))
                        .opacity(opacityFor(.local))
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Button {
                GraniteHaptic.light.invoke()
                page = .all
                all.fetch()
            } label: {
                VStack {
                    Spacer()
                    Text("LISTING_TYPE_ALL")
                        .font(fontFor(.all))
                        .opacity(opacityFor(.all))
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Button {
                GraniteHaptic.light.invoke()
                currentPager.fetch(force: true)
            } label: {
                VStack {
                    Spacer()
                    Image(systemName: "arrow.counterclockwise")
                        .font(.subheadline.bold())
                        .padding(.bottom, .layer1)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
        .frame(height: 36)
        .padding(.bottom, .layer4)
        .padding(.leading, .layer4)
        .padding(.trailing, .layer4)
        .foregroundColor(.foreground)
    }
}
