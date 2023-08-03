//
//  FeedSidebar.swift
//  Lemur
//
//  Created by PEXAVC on 7/30/23.
//

import Foundation
import SwiftUI
import Granite

struct FeedSidebar: View {
    
    
    var body: some View {
        VStack(spacing: 0) {
            CommunityPickerView(modal: false,
                                verticalPadding: 0,
                                sidebar: true)
            
        }
    }
}
