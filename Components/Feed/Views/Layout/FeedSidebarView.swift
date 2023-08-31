//
//  FeedSidebar.swift
//  Loom
//
//  Created by PEXAVC on 7/30/23.
//

import Foundation
import SwiftUI
import Granite
import FederationKit

struct FeedSidebar<Content: View>: View {
    @GraniteAction<(FederatedCommunityResource, FederatedData?)> var pickedCommunity
    
    let header: () -> Content
    init(@ViewBuilder header: @escaping (() -> Content) = { EmptyView() }) {
        self.header = header
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header()
            CommunityPickerView(modal: false,
                                shouldRoute: true,
                                verticalPadding: 0,
                                sidebar: true)
            .attach({ (model, federatedData) in
                pickedCommunity.perform((model, federatedData))
            }, at: \.pickedCommunity)
        }
    }
}
