//
//  Feed.Horizontal.swift
//  Loom
//
//  Created by PEXAVC on 7/29/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import LemmyKit

extension Feed {
    var minFrameWidth: CGFloat? {
        if Device.isMacOS {
            return 480
        } else if Device.isiPad {
            return 360
        } else {
            return nil
        }
    }
    
    var minFrameWidthClosed: CGFloat {
        200 + ContainerConfig.iPhoneScreenWidth + .layer1
    }
    
    //Primarily for macOS
    var horizontalLayout: some View {
        HStack(spacing: 0) {
            FeedSidebar() {
                headerView
            }
            .attach({ model in
                DispatchQueue.main.async {
                    self._state.community.wrappedValue = model.community
                    self._state.communityView.wrappedValue = model
                    self.pager.reset()
                }
            }, at: \.pickedCommunity)
            .frame(width: 300)
            Divider()
            FeedMainView(location: state.location,
                         communityView: state.communityView)
                .attach({ community in
                    fetchCommunity(community, reset: true)
                }, at: \.viewCommunity)
                .attach({ (model, metadata) in
                    DispatchQueue.main.async {
                        modal.presentSheet {
                            GraniteStandardModalView(title: "MISC_SHARE", fullWidth: Device.isMacOS) {
                                ShareModal(urlString: model?.post.ap_id) {
                                    PostCardView()
                                        .contentContext(.init(postModel: model,
                                                              viewingContext: .screenshot))
                                        .environment(\.pagerMetadata, metadata)
                                        .frame(width: ContainerConfig.iPhoneScreenWidth * 0.9)
                                }
                            }
                            .frame(width: Device.isMacOS ? 600 : nil)
                        }
                    }
                }, at: \.share)
                .graniteEvent(account.center.interact)
                .overlay(LogoView()
                    .attach({
                        modal.presentSheet {
                            Write(communityView: state.communityView)
                                .frame(width: Device.isMacOS ? 600 : nil, height: Device.isMacOS ? 500 : nil)
                        }
                    }, at: \.write))
                .environmentObject(pager)
                .frame(minWidth: minFrameWidth, maxWidth: nil)
            FeedExtendedView(location: state.location)
                .attach({ community in
                    fetchCommunity(community, reset: true)
                }, at: \.viewCommunity)
        }
    }
}
