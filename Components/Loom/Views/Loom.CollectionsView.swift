//
//  Loom.CollectionsView.swift
//  Loom
//
//  Created by Ritesh Pakala on 8/13/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI

struct LoomCollectionsView: View {
    @GraniteAction<LoomService.Modify.Intent> var add
    @GraniteAction<LoomManifest> var toggle
    
    @Binding var isCreaing: Bool
    @Binding var intent: Loom.Intent
    @Binding var activeManifest: LoomManifest?
    
    var manifests: [LoomManifest]
    
    
    var body: some View {
        //TODO: localize
        GraniteStandardModalView(title: "Looms",
                                 maxHeight: 600,
                                 showBG: true,
                                 fullWidth: true,
                                 drawerMode: true) {
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
                                    .background(.background.opacity(0.75))
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
                    isCreaing = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title)
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
        }
    }
}
