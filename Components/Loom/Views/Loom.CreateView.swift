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
import LemmyKit

struct LoomCreateView: View {
    @Binding var intent: Loom.Intent
    
    var communityView: CommunityView?
    
    @State var name: String = ""
    @State var invalidName: Bool = false
    
    @GraniteAction<String> var create
    
    var body: some View {
        //TODO: localize
        GraniteStandardModalView(title: "New Loom",
                                 showBG: true,
                                 fullWidth: true,
                                 drawerMode: true,
                                 shouldShowDrawer:  .init(get: {
                                    true
                                 }, set: { state in
                                    if !state {
                                        intent = .idle
                                    }
                                 })) {
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
                
                HStack {
                    Button {
                        GraniteHaptic.light.invoke()
                        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard trimmed.isNotEmpty else {
                            invalidName = true
                            return
                        }
                        create.perform(trimmed)
                        
                        if let communityView {
                            intent = .adding(communityView)
                        } else {
                            intent = .idle
                        }
                    } label: {
                        //TODO: localize
                        Text("Create")
                            .font(.headline)
                            .foregroundColor(.foreground)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
        }
    }
}
