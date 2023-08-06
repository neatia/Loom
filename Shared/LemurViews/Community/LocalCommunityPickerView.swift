//
//  LocalCommunityPickerView.swift
//  Lemur
//
//  Created by Ritesh Pakala on 8/6/23.
//

import Foundation
import LemmyKit
import SwiftUI
import Granite
import GraniteUI

struct LocalCommunityPreview: View {
    @GraniteAction<CommunityView> var pickedCommunity
    
    let url: String
    var client: Lemmy {
        .init(apiUrl: url)
    }
    var modal: Bool = false
    var verticalPadding: CGFloat = .layer5
    var sidebar: Bool = false
    
    @StateObject var local: Pager<CommunityView> = .init(emptyText: "EMPTY_STATE_NO_COMMUNITIES")
    
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
                    
                    HStack {
                        VStack {
                            Spacer()
                            Text("LISTING_TYPE_LOCAL")
                                .font(.title2.bold())
                        }
                        
                        Spacer()
                    }
                    .frame(height: 36)
                    .padding(.bottom, .layer4)
                    .padding(.leading, .layer4)
                    .padding(.trailing, .layer4)
                    .foregroundColor(.foreground)
                    
                    Divider()
                    
                    PagerScrollView(CommunityView.self,
                                    hideDivider: true) { communityView in
                        
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
                        
                        
                        if communityView.id != local.lastItem?.id {
                            Divider()
                                .padding(.leading, .layer3)
                        }
                    }
                    .environmentObject(local)
                    
                }
                .padding(.top, Device.isMacOS == false && modal ? .layer5 : 0)
            }
            .frame(maxHeight: modal ? 400 : nil)
        }
        .padding(.top, modal ? 0 : verticalPadding)
        .padding(.bottom, modal ? 0 : verticalPadding)
        .task {
            local.hook { page in
                await client.communities(.local, page: page)
            }.fetch()
        }
    }
}
