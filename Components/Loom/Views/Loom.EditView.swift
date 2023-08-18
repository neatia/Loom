//
//  Loom.EditView.swift
//  Loom
//
//  Created by PEXAVC on 8/14/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import LemmyKit

struct LoomEditView: View {
    @State var manifest: LoomManifest
    
    @State var removeCommunities: [FederatedCommunity] = []
    
    @State var invalidName: Bool = false
    
    @GraniteAction<LoomManifest> var edit
    @GraniteAction<LoomManifest> var remove
    
    var maxHeight: CGFloat? {
        return manifest.communities.isEmpty ? 210 : nil
    }
    
    var body: some View {
        //TODO: localize
        GraniteStandardModalView(maxHeight: maxHeight) {
            HStack(spacing: .layer4) {
                //TODO: localize
                Text("Edit Loom")
                    .font(.title.bold())
                
                Spacer()
                
                Button {
                    GraniteHaptic.light.invoke()
                    remove.perform(manifest)
                } label: {
                    Image(systemName: "trash")
                        .font(.headline.bold())
                        .foregroundColor(.red)
                }.buttonStyle(.plain)
                
                Button {
                    GraniteHaptic.light.invoke()
                    
                    let trimmed = manifest.meta.name.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard trimmed.isNotEmpty else {
                        invalidName = true
                        return
                    }
                    var mutable = manifest
                    mutable.communities.removeAll(where: { model in  removeCommunities.contains(where: { model.id == $0.id } ) })
                    
                    edit.perform(mutable)
                    
                } label: {
                    Image(systemName: "sdcard.fill")
                        .font(.title3)
                }.buttonStyle(.plain)
            }
            
        } content: {
            VStack(spacing: 0) {
                //TODO: localize
                TextField("Name", text: $manifest.meta.name)
                    .textFieldStyle(.plain)
                    .correctionDisabled()
                    .frame(height: 60)
                    .padding(.horizontal, .layer4)
                    .font(.title3.bold())
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color.tertiaryBackground)
                    )
                    .padding(.bottom, invalidName ? .layer2 : .layer4)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            StandardToolbarView()
                        }
                    }
                
                //TODO: localize
                if invalidName {
                    Text("Invalid name")
                        .font(.footnote)
                        .foregroundColor(.red.opacity(0.8))
                        .padding(.bottom, .layer4)
                }
                
                if manifest.communities.isNotEmpty {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: .layer4) {
                            ForEach(manifest.communities, id: \.id) { model in
                                let isRemoving: Bool = removeCommunities.contains(where: { $0.id == model.id })
                                ZStack {
                                    if let lemmyView = model.lemmy {
                                        CommunityCardView(model: lemmyView, showCounts: false)
                                    }
                                    
                                    Brand.Colors.black.opacity(0.75)
                                        .cornerRadius(8)
                                    
                                    
                                    Button {
                                        GraniteHaptic.light.invoke()
                                        if isRemoving {
                                            removeCommunities.removeAll(where: { $0.id == model.id })
                                        } else {
                                            removeCommunities.append(model)
                                        }
                                    } label: {
                                        
                                        if isRemoving {
                                            Image(systemName: "arrow.counterclockwise")
                                                .font(.headline.bold())
                                                .foregroundColor(.foreground)
                                        } else {
                                            Image(systemName: "trash")
                                                .font(.headline.bold())
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.bottom, .layer2)
                }
            }
        }
    }
}
