//
//  Profile.HeaderView.swift
//  Loom
//
//  Created by PEXAVC on 7/26/23.
//

import Foundation
import SwiftUI
import Granite
import Granite

extension Profile {
    var headerView: some View {
        HStack {
            
            if let person = state.person {
                AvatarView(state.person?.avatarURL, size: .large)
                
                VStack(spacing: .layer2) {
                    Text(person.name)
                        .font(.title2.bold())
                    if let displayName = person.display_name {
                        Text(displayName)
                            .font(.headline)
                    }
                    
                    if let domain = person.domain {
                        Text(domain)
                            .font(.headline)
                    }
                }
            }
            
            Spacer()
        }
    }
}
