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
    @Environment(\.presentationMode) var presentationMode
    
    @GraniteAction<LoomManifest> var toggle
    @GraniteAction<LoomManifest> var edit
    @GraniteAction<LoomManifest> var add
    
    @Relay var service: LoomService
    
    var manifests: [LoomManifest] {
        service.manifests
    }
    
    var modalIntent: Loom.Intent? = nil
    
    var intent: Loom.Intent {
        modalIntent ?? service.state.intent
    }
    
    var body: some View {
        VStack(spacing: .layer3) {
            if manifests.isNotEmpty {
                ScrollView(showsIndicators: false) {
                    Spacer()
                        .frame(height: 2)
                    VStack(spacing: .layer4) {
                        ForEach(manifests) { manifest in
                            LoomCardView(isActive: manifest == service.center.state.activeManifest,
                                         manifest: manifest)
                            .attach({ manifest in
                                service.center.modify.send(LoomService.Modify.Intent.toggle(manifest))
                            }, at: \.toggle)
                            .attach(edit, at: \.edit)
                            .attach(add, at: \.add)
                            .id(manifest)
                            .opacity(intent.isAdding ? 0.7 : 1.0)
                            .allowsHitTesting(intent.isAdding == false)
                            .overlayIf(intent.isAdding) {
                                HStack {
                                    Spacer()
                                    
                                    Button {
                                        switch intent {
                                        case .adding(let model):
                                            GraniteHaptic.light.invoke()
                                            
                                            service.center.modify.send(LoomService.Modify.Intent.add(model, manifest))
                                            
                                            presentationMode.wrappedValue.dismiss()
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
                    .padding(.layer4)
                }
                .frame(minHeight: manifests.count > 1 ? 400 : 240)
                .id(manifests)
            } else {
                Spacer()
                //TODO: localize
                Text("Create \"Looms\" of communities you'd like to see in 1 feed, here.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, .layer6)
                    .font(.headline)
                    .foregroundColor(Color.foreground)
                Spacer()
            }
        }
        .background(Color.background)
    }
}
