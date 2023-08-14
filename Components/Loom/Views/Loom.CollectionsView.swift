//
//  Loom.CollectionsView.swift
//  Loom
//
//  Created by PEXAVC on 8/13/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI

struct LoomCollectionsView: View {
    @GraniteAction<LoomService.Modify.Intent> var add
    @GraniteAction<LoomManifest> var toggle
    @GraniteAction<LoomManifest> var edit
    
    @Binding var intent: Loom.Intent
    @Binding var activeManifest: LoomManifest?
    
    var manifests: [LoomManifest]
    
    
    var body: some View {
        GraniteStandardModalView(maxHeight: 600,
                                 showBG: true,
                                 alternateBG: true,
                                 fullWidth: true,
                                 drawerMode: true) {
            HStack {
                //TODO: localize
                Text("Looms")
                    .font(.title.bold())
                Spacer()
                
                if intent.isAdding {
                    Button {
                        GraniteHaptic.light.invoke()
                        intent = .idle
                    } label: {
                        Text("MISC_DONE")
                            .font(.subheadline)
                            .lineLimit(1)
                            .readability()
                            .outline()
                    }.buttonStyle(.plain)
                }
            }
        } content: {
            VStack(spacing: .layer3) {
                if manifests.isNotEmpty {
                    ScrollView(showsIndicators: false) {
                        Spacer()
                            .frame(height: 2)
                        VStack(spacing: .layer4) {
                            ForEach(manifests) { manifest in
                                LoomCardView(isActive: manifest == activeManifest,
                                             manifest: manifest)
                                .attach({ manifest in
                                    toggle.perform(manifest)
                                }, at: \.toggle)
                                .attach({ manifest in
                                    edit.perform(manifest)
                                }, at: \.edit)
                                .opacity(intent.isAdding ? 0.7 : 1.0)
                                .allowsHitTesting(intent.isAdding == false)
                                .overlayIf(intent.isAdding) {
                                    HStack {
                                        Spacer()
                                        
                                        Button {
                                            switch intent {
                                            case .adding(let model):
                                                GraniteHaptic.light.invoke()
                                                add.perform(.add(model, manifest))
                                            default:
                                                break
                                            }
                                        } label: {
                                            if case .adding(let model) = intent, manifest.contains(model) {
                                                Image(systemName:  "checkmark.circle.fill")
                                                    .font(.title)
                                            } else {
                                                Image(systemName:  "plus.circle.fill")
                                                    .font(.title)
                                            }
                                        }.buttonStyle(.plain)
                                        
                                        Spacer()
                                    }
                                    .frame(maxHeight: .infinity)
                                    .clipped()
                                }
                            }
                        }
                    }
                    .frame(minHeight: manifests.count > 1 ? 400 : nil)
                } else {
                    Spacer()
                }
                
                Button {
                    GraniteHaptic.light.invoke()
                    intent = .creating
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.title)
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
        }
    }
}
