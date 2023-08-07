//
//  FeedSidebar.swift
//  Lemur
//
//  Created by PEXAVC on 7/30/23.
//

import Foundation
import SwiftUI
import Granite
import LemmyKit

struct FeedSidebar<Content: View>: View {
    @GraniteAction<CommunityView> var pickedCommunity
    
    let header: () -> Content
    init(@ViewBuilder header: @escaping (() -> Content) = { EmptyView() }) {
        self.header = header
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header()
            CommunityPickerView(modal: false,
                                verticalPadding: 0,
                                sidebar: true)
            .attach({ model in
                pickedCommunity.perform(model)
            }, at: \.pickedCommunity)
        }
    }
}
