//
//  GraniteStandardView.swift
//  Lemur
//
//  Created by PEXAVC on 7/22/23.
//

import Foundation
import SwiftUI

struct GraniteStandardView<Content: View>: View {
    var title: String?
    var content: (() -> Content)
    
    init(title: String? = nil,
         @ViewBuilder view: @escaping (() -> Content)) {
        self.title = title
        self.content = view
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let title {
                HStack(spacing: .layer4) {
                    VStack {
                        Spacer()
                        Text(title)
                            .font(.title.bold())
                    }
                    
                    Spacer()
                }
                .frame(height: 36)
                .padding(.bottom, .layer4)
                .padding(.leading, .layer4)
                .padding(.trailing, .layer4)
                Divider()
            }
            
            content()
        }
        .padding(.top, .layer5)
        .padding(.bottom, .layer5)
    }
}
