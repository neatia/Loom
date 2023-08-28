//
//  LoomsPickerView.swift
//  Loom
//
//  Created by Ritesh Pakala on 8/27/23.
//

import Foundation
import LemmyKit
import SwiftUI
import Granite
import GraniteUI

struct LoomPickerView: View {
    
    @Relay var loom: LoomService
    
    var communities: Pager<CommunityView> = .init(emptyText: "EMPTY_STATE_NO_COMMUNITIES", isStatic: true)
    
    @State var idPicked: String = ""
    
    func opacityFor(_ id: String) -> CGFloat {
        return self.idPicked == id ? 1.0 : 0.6
    }
    
    func fontFor(_ id: String) -> Font {
        return self.idPicked == id ? .title2.bold() : .title3.bold()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            selectorView
            Divider()
            
            if let manifest = loom.manifest(for: idPicked) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        //TODO: maintain generic when fedkit is implemented
                        ForEach(manifest.communities.compactMap { $0.lemmy }) { communityView in
                            CommunityCardView(model: communityView, style: .style2)
                        }
                    }
                }
                .frame(maxHeight: 300)
                .padding(.top, .layer4)
            }
            Spacer()
        }
        .task {
            idPicked = loom.manifests.first?.id.uuidString ?? ""
        }
    }
}

extension LoomPickerView {
    var selectorView: some View {
        
        ScrollView([.horizontal], showsIndicators: false) {
            HStack(spacing: .layer4) {
                ForEach(loom.manifests) { manifest in
                    Button {
                        GraniteHaptic.light.invoke()
                        idPicked = manifest.id.uuidString
                    } label: {
                        VStack {
                            Spacer()
                            Text(manifest.meta.name)
                                .font(fontFor(manifest.id.uuidString))
                                .opacity(opacityFor(manifest.id.uuidString))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
                
            }
        }
        .frame(height: 36)
        .padding(.bottom, .layer4)
        .foregroundColor(.foreground)
    }
}
