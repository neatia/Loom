//
//  CommunitySidebar.swift
//  Loom
//
//  Created by PEXAVC on 7/28/23.
//

import Foundation
import SwiftUI
import Granite
import MarkdownView
import FederationKit

struct CommunitySidebarView: View {
    var communityView: FederatedCommunityResource?
    
    var community: FederatedCommunity? {
        communityView?.community
    }
    //@State var communityView: FederatedCommunityResource? = nil
    
    var body: some View {
        GraniteStandardModalView(maxHeight: nil,
                                 customHeaderView: true) {
            Group {
                if let communityView {
                    CommunityCardView(model: communityView,
                                      fullWidth: true,
                                      outline: true)
                }
            }
        } content: {
            VStack(spacing: .layer2) {
//                //TODO: admin list
//                if let FederatedCommunityResource{
//                    HStack(spacing: .layer4) {
//                        VStack {
//                            Spacer()
//                            Text("TITLE_ADMINS")
//                                .font(.title.bold())
//                        }
//
//                        Spacer()
//                    }
//                    .frame(height: 36)
//                }
                
                ScrollView(showsIndicators: false) {
                    if let description = community?.description {
                        MarkdownView(text: description)
                            .markdownViewRole(.editor)
                            .padding(.layer3)
                            .background(Color.tertiaryBackground)
                            .cornerRadius(8)
                    }
                }
                Spacer()
            }
        }
//        .task {
//            let FederatedCommunityResource= await Lemmy.community(community: community)
//            self.FederatedCommunityResource= communityView
//        }
    }
}
