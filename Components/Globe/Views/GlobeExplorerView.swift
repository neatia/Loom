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
import FederationKit

struct GlobeExplorerView: View {
    @Environment(\.graniteEvent) var restart
    
    @State var instances: [String: FederatedInstance] = [:]
    @State var globeInstances: [FederatedInstance] = []
    @State var searchedInstances: [FederatedInstance] = []
    @State var randomSelection: [FederatedInstance] = []
    
    @State var searchBox: BasicKeySearchBox = .init(keys: [])
    @State var isReady: Bool = false
    
    @State var connected: FederatedInstance = .base
    
    @Relay var explorer: ExplorerService
    
    @State var instancesViewingOption: Int = 0
    
    var hasFavorites: Bool {
        explorer.state.favorites.values.isEmpty == false
    }
    
    var body: some View {
        VStack {
            if Device.isExpandedLayout {
                landscapeView
            } else {
                searchView
            }
        }
        .onChange(of: explorer.state.lastUpdate) { _ in
            update()
        }
        .onAppear {
            if explorer.isLoaded && instances.isEmpty {
                explorer.center.boot.send()
            }
        }
        .clipped()
    }
    
    func update() {
        //self.instances = [Instance.base] + explorer.state.linkedInstances
        DispatchQueue.global(qos: .background).async {
            var keys: [String] = []
            var instancesToUpdate: [String: FederatedInstance] = [:]
            
            explorer.state.linkedInstances.forEach { instance in
                keys.append(instance.domain)
                instancesToUpdate[instance.domain] = instance
            }
            
            DispatchQueue.main.async {
                self.instances = instancesToUpdate
                self.searchBox = .init(keys: keys)
                self.randomize()
            }
        }
        
        self.isReady = true
    }
    
    func randomize() {
        DispatchQueue.global(qos: .userInteractive).async {
            let count: Int = explorer.state.linkedInstances.count
            let randomIndex: Int = min(max(count - 2, 0), 2.randomBetween(count - 36))
            let randomLimit: Int = min(max(count - 1, 0), randomIndex + 12.randomBetween(36))
            
            let randomInstances: [FederatedInstance] = Array(explorer.state.linkedInstances[randomIndex..<randomLimit])
            
            DispatchQueue.main.async {
                self.randomSelection = randomInstances
            }
        }
        
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
                GlobeView(globeInstances)
                    .wip()
            }
            
            Divider()

            searchView
        }
    }
    
    var searchView: some View {
        VStack(spacing: 0) {
            if searchedInstances.isEmpty || Device.isExpandedLayout {
                InstanceCardView(connected,
                                 isConnected: true,
                                 isFavorite: explorer.state.favorites[connected.domain] != nil)
                .attach({ instance in
                    if explorer._state.favorites.wrappedValue[instance.domain] == nil {
                        explorer._state.favorites.wrappedValue[instance.domain] = instance
                    } else {
                        explorer._state.favorites.wrappedValue[instance.domain] = nil
                    }
                }, at: \.favorite)
                .padding(.layer3)
                .id(connected.domain)
            }
            
            Divider()
            
            SearchBar(debounceInterval: 2)
                .attach({ query in
                    search(query)
                }, at: \.query)
                .attach({
                    searchedInstances.removeAll()
                }, at: \.clean)
            Divider()

            if searchedInstances.isNotEmpty {
                GraniteScrollView {
                    LazyVStack(spacing: .layer3) {
                        ForEach(searchedInstances) { instance in
                            InstanceCardView(instance,
                                             isConnected: connected.domain == instance.domain,
                                             isFavorite: explorer.state.favorites[instance.domain] != nil)
                                .attach({ instance in
                                    self.connected = instance
                                }, at: \.connect)
                                .attach({ instance in
                                    if explorer._state.favorites.wrappedValue[instance.domain] == nil {
                                        explorer._state.favorites.wrappedValue[instance.domain] = instance
                                    } else {
                                        explorer._state.favorites.wrappedValue[instance.domain] = nil
                                    }
                                }, at: \.favorite)
                                .graniteEvent(restart)
                                .padding(.horizontal, .layer3)
                        }
                    }
                    .padding(.vertical, .layer2)
                }
            } else {
                
                VStack(spacing: 0) {
                    
                    if hasFavorites {
                        VStack(spacing: 0) {
                            Picker("", selection: $instancesViewingOption) {
                                //TODO: localize
                                Text("Favorites").tag(0)
                                //TODO: localize
                                Text("Random").tag(1)
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(.layer3)
                    }
                    if instancesViewingOption == 0 && hasFavorites {
                        favoriteView
                    } else {
                        randomSelectionView
                            .onAppear {
                                randomize()
                            }
                    }
                }
            }
        }
    }
    
    var favoriteView: some View {
        VStack(spacing: 0) {
            
            GraniteScrollView {
                LazyVStack(spacing: .layer3) {
                    ForEach(Array(explorer.state.favorites.values.filter { $0.domain != connected.domain })) { instance in
                        InstanceCardView(instance,
                                         isConnected: connected.domain == instance.domain,
                                         isFavorite: explorer.state.favorites[instance.domain] != nil)
                            .attach({ instance in
                                self.connected = instance
                            }, at: \.connect)
                            .attach({ instance in
                                if explorer._state.favorites.wrappedValue[instance.domain] == nil {
                                    explorer._state.favorites.wrappedValue[instance.domain] = instance
                                } else {
                                    explorer._state.favorites.wrappedValue[instance.domain] = nil
                                }
                            }, at: \.favorite)
                            .graniteEvent(restart)
                            .padding(.horizontal, .layer3)
                    }
                }
                .padding(.top, .layer2)
                .padding(.bottom, .layer3)
            }
        }
    }
    
    var randomSelectionView: some View {
        GraniteScrollView {
            LazyVStack(spacing: .layer3) {
                ForEach(randomSelection) { instance in
                    InstanceCardView(instance,
                                     isConnected: connected.domain == instance.domain,
                                     isFavorite: explorer.state.favorites[instance.domain] != nil)
                        .attach({ instance in
                            self.connected = instance
                        }, at: \.connect)
                        .attach({ instance in
                            if explorer._state.favorites.wrappedValue[instance.domain] == nil {
                                explorer._state.favorites.wrappedValue[instance.domain] = instance
                            } else {
                                explorer._state.favorites.wrappedValue[instance.domain] = nil
                            }
                        }, at: \.favorite)
                        .graniteEvent(restart)
                        .padding(.horizontal, .layer3)
                }
            }
            .padding(.top, hasFavorites ? .layer2 : .layer3)
            .padding(.bottom, .layer3)
        }
    }
}

fileprivate extension View {
    func showDrawer(_ condition: Bool,
                    instance: FederatedInstance?,
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
