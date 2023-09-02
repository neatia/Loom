//
//  Loom.Views.swift
//  Loom
//
//  Created by PEXAVC on 8/13/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI

struct LoomCardView: View {
    @GraniteAction<LoomManifest> var toggle
    @GraniteAction<LoomManifest> var edit
    @GraniteAction<LoomManifest> var add
    
    var isActive: Bool = false
    var manifest: LoomManifest
    
    var collectionNamesList: [String] {
        manifest.collectionNamesList
    }
    
    var collectionNames: String {
        manifest.collectionNames
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text(manifest.meta.name)
                    .font(.title3.bold())
                Spacer()
            }
            .padding(.bottom, .layer2)
            .foregroundColor(.foreground)
            
            HStack(spacing: 0) {
                if collectionNames.isNotEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: .layer3) {
                            ForEach(manifest.data) { fd in
                                Group {
                                    if let lemmyView = fd.community {
                                        CommunityCardView(model: lemmyView,
                                                          shouldRoute: true,
                                                          showCounts: false,
                                                          federatedData: fd)
                                        .frame(minWidth: 240)
                                        .outline()
                                    } else {
                                        EmptyView()
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    .foregroundColor(.foreground)
                    .padding(.trailing, .layer4)
                } else {
                    Text("EMPTY_STATE_NO_COMMUNITIES")
                        .font(.subheadline)
                        .readability()
                        .outline()
                }
                
                Spacer()
                
                Button {
                    GraniteHaptic.light.invoke()
                    toggle.perform(manifest)
                } label: {
                    Image(systemName: "rectangle.\(isActive ? "righthalf" : "lefthalf").inset.filled")
                        .font(.title)
                        .foregroundColor(.foreground.opacity(0.8))
                        .padding(-4)
                        .backgroundIf(isActive) { Color.green.opacity(0.6) }
                        .padding(.horizontal, .layer2)
                }.buttonStyle(.plain)
            }
            
            HStack(spacing: 0) {
                Text(manifest.meta.updatedDate.asString)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(.foreground.opacity(0.5))
                Spacer()
                
                Button {
                    GraniteHaptic.light.invoke()
                    edit.perform(manifest)
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.headline)
                }
                .buttonStyle(.plain)
                .padding(.trailing, .layer4)
                
                Button {
                    GraniteHaptic.light.invoke()
                    add.perform(manifest)
                } label: {
                    Image(systemName: "plus")
                        .font(.headline)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, .layer2)
        }
        .padding(.leading, .layer1)
        .readability()
        .outline()
    }
}
