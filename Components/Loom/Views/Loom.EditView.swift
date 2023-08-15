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
    @Binding var intent: Loom.Intent
    
    @State var manifest: LoomManifest
    
    @State var removeCommunities: [CommunityView] = []
    
    @State var invalidName: Bool = false
    
    @GraniteAction<LoomManifest> var edit
    
    var body: some View {
        //TODO: localize
        GraniteStandardModalView(title: "Edit Loom",
                                 maxHeight: 600,
                                 showBG: true,
                                 alternateBG: true,
                                 fullWidth: true,
                                 drawerMode: true,
                                 shouldShowDrawer: .init(get: {
                                    true
                                 }, set: { state in
                                    if !state {
                                        intent = .idle
                                    }
                                 })) {
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
                            .foregroundColor(Color.background)
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
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: .layer4) {
                        ForEach(manifest.communities) { model in
                            let isRemoving: Bool = removeCommunities.contains(model)
                            ZStack {
                                CommunityCardView(model: model, showCounts: false)
                                
                                Brand.Colors.black.opacity(0.75)
                                    .cornerRadius(8)
                                
                                
                                Button {
                                    GraniteHaptic.light.invoke()
                                    if isRemoving {
                                        removeCommunities.removeAll(where: { $0 == model })
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
                
                HStack {
                    Button {
                        GraniteHaptic.light.invoke()
                        let trimmed = manifest.meta.name.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard trimmed.isNotEmpty else {
                            invalidName = true
                            return
                        }
                        var mutable = manifest
                        mutable.communities.removeAll(where: { removeCommunities.contains($0) })
                        edit.perform(mutable)
                        intent = .idle
                    } label: {
                        //TODO: localize
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.foreground)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, .layer4)
                Spacer()
            }
        }
    }
}
