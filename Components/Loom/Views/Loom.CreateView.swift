//
//  Loom.CreateView.swift
//  Loom
//
//  Created by Ritesh Pakala on 8/13/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI

struct LoomCreateView: View {
    @Binding var isCreating: Bool
    @State var name: String = ""
    @State var invalidName: Bool = false
    
    @GraniteAction<String> var create
    
    var body: some View {
        //TODO: localize
        GraniteStandardModalView(title: "New Loom",
                                 showBG: true,
                                 fullWidth: true,
                                 drawerMode: true,
                                 shouldShowDrawer: $isCreating) {
            VStack(spacing: 0) {
                //TODO: localize
                TextField("Name", text: $name)
                    .textFieldStyle(.plain)
                    .correctionDisabled()
                    .textContentType(.username)
                    .frame(height: 60)
                    .padding(.horizontal, .layer4)
                    .font(.title3.bold())
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color.tertiaryBackground)
                    )
                    .padding(.bottom, .layer4)
                
                //TODO: localize
                if invalidName {
                    Text("Invalid name")
                        .font(.footnote)
                        .foregroundColor(.red.opacity(0.8))
                }
                Spacer()
                HStack {
                    Button {
                        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard trimmed.isNotEmpty else {
                            invalidName = true
                            return
                        }
                        create.perform(trimmed)
                    } label: {
                        //TODO: localize
                        Text("Create")
                            .font(.headline)
                            .foregroundColor(.foreground)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
