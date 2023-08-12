//
//  InfoIconView.swift
//  Stoic
//
//  Created by PEXAVC on 4/30/23.
//

import Foundation
import SwiftUI
import GraniteUI

struct InfoIconView: View {
    var text: LocalizedStringKey
    var modal: ModalService
    var body: some View {
        //TODO: modal bug with macOS (maxHeight)
        VStack {
            Text("i")
                .font(.caption2.bold())
                .foregroundColor(.foreground)
                .background(Circle().strokeBorder(.foreground, lineWidth: 1).frame(width: 16, height: 16))
        }
        .onTapGesture {
            GraniteHaptic.light.invoke()
            modal.presentModal(GraniteAlertView(message: text) {
                
                GraniteAlertAction(title: "MISC_DONE")
            })
        }
    }
}

extension View {
    func addInfoIcon(text: LocalizedStringKey, spacing: CGFloat = .layer4, _ modalService: ModalService, direction: HorizontalAlignment = .trailing ) -> some View {
        HStack(spacing: spacing) {
            if direction == .leading {
                InfoIconView(text: text, modal: modalService)
            }
            self
            if direction == .trailing {
                InfoIconView(text: text, modal: modalService)
            }
        }
    }
    func addInfoIconIf(_ condition: Bool, text: LocalizedStringKey, spacing: CGFloat = .layer4, _ modalService: ModalService, direction: HorizontalAlignment = .trailing ) -> some View {
        Group {
            if condition {
                self.addInfoIcon(text: text, spacing: spacing, modalService, direction: direction)
            } else {
                self
            }
        }
    }
}
