//
//  Write.Set.swift
//  Loom (iOS)
//
//  Created by PEXAVC on 7/21/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI

extension Write {
    func setPostURL() {
        let lastState: String = state.postURL
        var value: String = ""
        var bindingString = Binding<String>.init(get: {
            return value
        }, set: { newValue in
            value = newValue
        })
        modal.presentSheet(id: Write.modalId, detents: [.large]) {
            GraniteStandardModalView(title: "TITLE_SET_URL", maxHeight: 210) {
                VStack(spacing: 0) {
                    TextField("MISC_URL", text: bindingString)
                        .textFieldStyle(.plain)
                        .correctionDisabled()
                        .frame(height: 60)
                        .padding(.horizontal, .layer4)
                        .font(.title3.bold())
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(Color.alternateBackground.opacity(0.3))
                        )
                    
                    HStack(spacing: .layer2) {
                        Spacer()
                        
                        Button {
                            GraniteHaptic.light.invoke()
                            _state.postURL.wrappedValue = lastState
                            modal.dismissSheet(id: Write.modalId)
                        } label: {
                            Text("MISC_CANCEL")
                                .font(.headline)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.trailing, .layer2)
                        
                        Button {
                            GraniteHaptic.light.invoke()
                            _state.postURL.wrappedValue = ""
                            modal.dismissSheet(id: Write.modalId)
                        } label: {
                            Text("MISC_REMOVE")
                                .font(.headline)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.trailing, .layer2)
                        
                        Button {
                            GraniteHaptic.light.invoke()
                            _state.postURL.wrappedValue = value
                            modal.dismissSheet(id: Write.modalId)
                        } label: {
                            Text("MISC_DONE")
                                .font(.headline)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                    }
                    .padding(.top, .layer4)
                }
            }
        }
    }
}

extension Write {
    func setCommunity() {
        modal.presentSheet(id: Write.modalId, detents: [.large]) {
            CommunityPickerView()
                .attach({ (communityView, federatedData) in
                    GraniteHaptic.light.invoke()
                    _state.postCommunity.wrappedValue = communityView
                    modal.dismissSheet(id: Write.modalId)
                }, at: \.pickedCommunity)
                .frame(width: Device.isMacOS ? 400 : nil, height: Device.isMacOS ? 400 : nil)
        }
    }
}
