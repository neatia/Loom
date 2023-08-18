//
//  CommunitySidebar.swift
//  Loom
//
//  Created by PEXAVC on 7/28/23.
//

import Foundation
import SwiftUI
import Granite
import LemmyKit
import MarkdownView

struct CommunitySidebarView: View {
    var communityView: CommunityView
    
    var community: Community {
        communityView.community
    }
    //@State var communityView: CommunityView? = nil
    
    var body: some View {
        GraniteStandardModalView(maxHeight: 600,
                                 customHeaderView: true) {
            Group {
                if let communityView {
                    CommunityCardView(model: communityView, fullWidth: true)
                }
            }
        } content: {
            VStack {
                ScrollView(showsIndicators: false) {
                    if let description = community.description {
                        MarkdownView(text: description)
                            .markdownViewRole(.editor)
                            .padding(.layer3)
                            .background(Color.tertiaryBackground)
                            .cornerRadius(8)
                    }
                    
                    //TODO: admin list
                    if let communityView {
                        HStack(spacing: .layer4) {
                            VStack {
                                Spacer()
                                Text("TITLE_ADMINS")
                                    .font(.title.bold())
                            }
                            
                            Spacer()
                        }
                        .frame(height: 36)
                    }
                }
                Spacer()
            }
        }
//        .task {
//            let communityView = await Lemmy.community(community: community)
//            self.communityView = communityView
//        }
    }
}
