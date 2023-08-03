//
//  Draft.Actions.swift
//  Lemur
//
//  Created by Ritesh Pakala on 7/22/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI

extension Draft {
    func createCategory() {
        modal.presentSheet {
            GraniteSheetView(title: "Create Category", height: 140) {
                VStack(spacing: 0) {
                    TextField("Name", text: _state.newCategoryName)
                        .textFieldStyle(.plain)
                        .frame(height: 40)
                        .padding(.horizontal, .layer4)
                        .font(.title3.bold())
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(state.categoryExists ? Color.red.opacity(0.5) : Color.black.opacity(0.3))
                        )
                        .frame(minWidth: Device.isMacOS ? 400 : nil)
                    
                    if state.categoryExists {
                        Text("Please pick a unique category name")
                            .font(.headline.bold())
                            .foregroundColor(Color.red.opacity(0.7))
                    }
                    
                    HStack(spacing: .layer2) {
                        Spacer()
                        
                        Button {
                            GraniteHaptic.light.invoke()
                            modal.dismissSheet()
                        } label: {
                            Text("Cancel")
                                .font(.headline)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.trailing, .layer2)
                        
                        Button {
                            GraniteHaptic.light.invoke()
                            guard service.state.categories.filter({ $0.title.lowercased() == state.newCategoryName.lowercased() }).isEmpty else {
                                
                                _state.categoryExists.wrappedValue = true
                                return
                            }
                            service.center.createCategory.send(DraftService.CreateCategory.Meta(category: .init(title: state.newCategoryName, manuscriptIDs: [])))
                            _state.newCategoryName.wrappedValue = ""
                        } label: {
                            Text("Create")
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
