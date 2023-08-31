//
//  Loom.CreateView.swift
//  Loom
//
//  Created by PEXAVC on 8/13/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import FederationKit

struct LoomCreateView: View {
    var communityView: FederatedCommunityResource?
    
    @State var name: String = ""
    @State var invalidName: Bool = false
    
    @GraniteAction<String> var create
    
    var body: some View {
        //TODO: localize
        GraniteStandardModalView(maxHeight: 210) {
            HStack(spacing: .layer4) {
                //TODO: localize
                Text("New Loom")
                    .font(.title.bold())
                
                Spacer()
                
                Button {
                    GraniteHaptic.light.invoke()
                    let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard trimmed.isNotEmpty else {
                        invalidName = true
                        return
                    }
                    create.perform(trimmed)
                } label: {
                    Image(systemName: "checkmark")
                        .font(.title3)
                }.buttonStyle(.plain)
            }
        } content: {
            VStack(spacing: 0) {
                //TODO: localize
                TextField("Name", text: $name)
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
                
                //TODO: localize
                if invalidName {
                    Text("Invalid name")
                        .font(.footnote)
                        .foregroundColor(.red.opacity(0.8))
                        .padding(.bottom, .layer4)
                }
            }
        }
    }
}
