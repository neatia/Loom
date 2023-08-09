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
    @Relay var explorer: ExplorerService
    @Environment(\.graniteEvent) var restart
    
    @State var instances: [String: Instance] = [:]
    @State var searchedInstances: [Instance] = []
    
    @State var searchBox: BasicKeySearchBox = .init(keys: [])
    @State var isReady: Bool = false
    
    var body: some View {
        VStack {
            #if os(iOS)
            searchView
            #else
            landscapeView
            #endif
        }
        .onChange(of: explorer.isLoaded) { _ in
            explorer.center.boot.send()
        }
        .onChange(of: explorer.state.lastUpdate) { _ in
            DispatchQueue.main.async {
                update()
                LoomLog("found \(self.instances.count) instances", level: .debug)
            }
        }
        .onAppear {
            update()
        }
        .clipped()
    }
    
    func update() {
        //self.instances = [Instance.base] + explorer.state.linkedInstances
        var keys: [String] = []
        explorer.state.linkedInstances.forEach { instance in
            keys.append(instance.domain)
            self.instances[instance.domain] = instance
        }
        self.searchBox = .init(keys: keys)
        
        self.isReady = true
    }
    
    func search(_ query: String) {
        let results = searchBox.search(query)
        let instances = results.compactMap {
            self.instances[$0]
        }
        self.searchedInstances = instances
    }
}

extension GlobeExplorerView {
    var landscapeView: some View {
        HStack(spacing: 0) {
            if isReady {
                GlobeView()
                    .wip()
            }
            
            Divider()

            searchView
        }
    }
    
    var searchView: some View {
        VStack(spacing: 0) {
            SearchBar(debounceInterval: 2)
                .attach({ query in
                    search(query)
                }, at: \.query)
                .attach({
                    searchedInstances.removeAll()
                }, at: \.clean)
            Divider()
            
            Spacer()

            if searchedInstances.isNotEmpty {
                GraniteScrollView {
                    LazyVStack(spacing: .layer3) {
                        ForEach(searchedInstances) { instance in
                            InstanceCardView(instance, isFavorite: explorer.state.favorites[instance.domain] != nil)
                                .attach({ instance in
                                    
                                }, at: \.connect)
                                .attach({ instance in
                                    if explorer._state.favorites.wrappedValue[instance.domain] == nil {
                                        explorer._state.favorites.wrappedValue[instance.domain] = instance
                                    } else {
                                        explorer._state.favorites.wrappedValue[instance.domain] = nil
                                    }
                                }, at: \.favorite)
                                .padding(.horizontal, .layer3)
                        }
                    }
                }
            } else if explorer.state.favorites.values.isEmpty {
                //TODO: localize
                Text("Search for an instance via their domain.")
                    .font(.headline)
                
                Spacer()
            } else {
                favoriteView
            }
        }
    }
    
    var favoriteView: some View {
        VStack(spacing: 0) {
            //TODO: localize
            HStack {
                Text("\(explorer.state.favorites.count) Favorites")
                    .font(.title2.bold())
                    .foregroundColor(.foreground)
                Spacer()
            }
            .padding(.top, .layer3)
            .padding(.bottom, .layer2)
            .padding(.horizontal, .layer3)
            Divider()
            
            GraniteScrollView {
                LazyVStack(spacing: .layer3) {
                    ForEach(Array(explorer.state.favorites.values)) { instance in
                        InstanceCardView(instance, isFavorite: explorer.state.favorites[instance.domain] != nil)
                            .attach({ instance in
                                
                            }, at: \.connect)
                            .attach({ instance in
                                if explorer._state.favorites.wrappedValue[instance.domain] == nil {
                                    explorer._state.favorites.wrappedValue[instance.domain] = instance
                                } else {
                                    explorer._state.favorites.wrappedValue[instance.domain] = nil
                                }
                            }, at: \.favorite)
                            .padding(.horizontal, .layer3)
                    }
                }.padding(.top, .layer3)
            }
        }
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
