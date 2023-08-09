//
//  GlobeExplorer.swift
//  Loom
//
//  Created by PEXAVC on 8/4/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import LemmyKit

struct GlobeExplorerView: View {
    var radius: CGFloat = 50
    @Relay var explorer: ExplorerService
    @Environment(\.graniteEvent) var restart
    
    @State var instances: [Instance] = []
    
    var body: some View {
        VStack {
            if instances.count > 1 {
                GlobeView(instances)
            } else {
                Spacer()
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                Spacer()
            }
        }
        //TODO: reusable
        .overlay(
            VStack {
                HStack {
                    HStack {
                        Text("⚠️ ") + Text("ALERT_WORK_IN_PROGRESS")

                    }
                    .padding(.vertical, .layer1)
                    .padding(.horizontal, .layer2)
                    .background(Color.tertiaryBackground.cornerRadius(8))
                    Spacer()

                    Button {
                        GraniteHaptic.light.invoke()

                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.headline.bold())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.vertical, .layer1)
                    .padding(.horizontal, .layer2)
                }
                Spacer()
            }
            .padding(.layer4)

        )
        .task {
            explorer.preload()
            
            //TODO: counts can change, compare dates instead of count check
            guard explorer.state.lastUpdate == nil || explorer.state.linkedInstances.isEmpty else {
                self.instances = [Instance.base] + explorer.state.linkedInstances
                LoomLog("found \(self.instances.count) instances", level: .debug)
                return
            }
            
            explorer.center.boot.send()
            
            self.instances = [Instance.base] + explorer.state.linkedInstances
            LoomLog("found \(self.instances.count) instances", level: .debug)
            
        }
        .clipped()
    }
}

fileprivate extension View {
    func showDrawer(_ condition: Bool,
                    instance: Instance?,
                    event: EventExecutable? = nil) -> some View {
        self.overlayIf(condition && instance != nil, alignment: .top) {
            Group {
                #if os(iOS)
                if let instance {
                    Drawer(startingHeight: 100) {
                        ZStack(alignment: .top) {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(Color.background)
                                .shadow(radius: 100)
                            
                            VStack(alignment: .center, spacing: 0) {
                                RoundedRectangle(cornerRadius: 8)
                                    .frame(width: 50, height: 8)
                                    .foregroundColor(Color.gray)
                                    .padding(.top, .layer5)
                                
                                InstanceMetaView(instance)
                                    .graniteEvent(event)
                                Spacer()
                            }
                            .frame(height: UIScreen.main.bounds.height - 100)
                        }
                    }
                    .rest(at: .constant([100, 480, UIScreen.main.bounds.height - 100]))
                    .impact(.light)
                    .edgesIgnoringSafeArea(.vertical)
                    .transition(.move(edge: .bottom))
                    .id(instance.domain)
                }
                #endif
            }
        }
    }
}
