//
//  InstanceSymbolView.swift
//  Loom
//
//  Created by PEXAVC on 9/3/23.
//

import Foundation
import SwiftUI
import FederationKit

struct InstanceSymbolView: View {
    
    let instanceType: FederatedInstanceType
    
    init(_ instanceType: FederatedInstanceType) {
        self.instanceType = instanceType
    }
    
    var body: some View {
        Group {
            switch instanceType {
            case .mastodon:
                Text("mastodon")
                    .font(.footnote)
                    .foregroundColor(Brand.Colors.purple.opacity(0.8))
            case .rss:
                Text("rss")
                    .font(.footnote)
                    .foregroundColor(Color.orange)
            default:
                EmptyView()
            }
        }
    }
}
