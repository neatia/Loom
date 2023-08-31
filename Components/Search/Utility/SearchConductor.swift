//
//  Search.swift
//  Loom
//
//  Created by PEXAVC on 7/25/23.
//

import Foundation
import Granite
import GraniteUI
import SwiftUI
import Combine
import FederationKit

class SearchConductor: ObservableObject {
    var searchTimer: Cancellable? = nil
    private var task: Task<Void, Error>? = nil
    
    @Published var isEditing: Bool = false
    //TODO: cleanup, using view @state for this
    @Published var isSearching: Bool = false
    @Published var response: FederatedSearchResult? = nil
    var lastQuery: String = ""
    
    var isEmpty: Bool {
        response == nil
    }
    
    private var handler: ((String) async -> FederatedSearchResult?)?
    
    internal var cancellables: Set<AnyCancellable> = .init()
    
    init() {
        self.handler = nil
    }
    
    @discardableResult
    func hook(_ commit: @escaping ((String) async -> FederatedSearchResult?)) -> Self {
        self.handler = commit
        return self
    }
    
    //basic debouncing
    func startTimer(_ query: String) {
        self.lastQuery = query
        searchTimer?.cancel()
        searchTimer = nil
        if isSearching == false {
            DispatchQueue.main.async { [weak self] in
                self?.isSearching = true
            }
        }
        searchTimer = Timer.publish(every: 1,
                                    on: .main,
                                    in: .common)
          .autoconnect()
          .sink(receiveValue: { [weak self] (output) in
              self?.searchTimer?.cancel()
              self?.isSearching = false
              print("[Executing Query] \(query)")
              self?.search(query)
          })
    }
    
    func search(_ query: String) {
        let q = query
        searchTimer?.cancel()
        searchTimer = nil
        self.task?.cancel()
        //self.isSearching = true
        self.task = Task.detached(priority: .background) { [weak self] in
            let response = await self?.handler?(q)
            DispatchQueue.main.async { [weak self] in
                GraniteHaptic.light.invoke()
                
                LoomLog("🔎 search result recieved 🔎", level: .debug)
                
                self?.response = response
                //self?.isSearching = false
                self?.lastQuery = q
            }
        }
    }
    
    func clean() {
        isSearching = false
        self.task?.cancel()
        self.task = nil
        searchTimer?.cancel()
        searchTimer = nil
        self.lastQuery = ""
    }
    
    func reset() {
        self.response = nil
        self.clean()
    }
}
