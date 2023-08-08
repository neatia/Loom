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
import LemmyKit

class SearchConductor: ObservableObject {
    var searchTimer: Cancellable? = nil
    private var task: Task<Void, Error>? = nil
    
    @Published var isEditing: Bool = false
    //TODO: cleanup, using view @state for this
    @Published var isSearching: Bool = false
    @Published var response: SearchResponse? = nil
    var lastQuery: String = ""
    
    var isEmpty: Bool {
        response == nil
    }
    
    private var handler: ((String) async -> SearchResponse?)?
    
    internal var cancellables: Set<AnyCancellable> = .init()
    
    init() {
        self.handler = nil
    }
    
    @discardableResult
    func hook(_ commit: @escaping ((String) async -> SearchResponse?)) -> Self {
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
//              self?.isSearching = false
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
}


struct SearchBar: View {
    @EnvironmentObject var conductor: SearchConductor
    @StateObject var textDebouncer = TextDebouncer()
    
    @State var isSearching: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                if (Device.isMacOS && isSearching == false) || (Device.isMacOS == false) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .frame(width: 20, height: 20, alignment: .leading)
                            .padding(.leading, .layer4)
                            .foregroundColor(Brand.Colors.grey)
                        
                        TextField("MISC_SEARCH",
                                  text: $textDebouncer.text)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.headline.bold())
                        .autocorrectionDisabled(true)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                StandardToolbarView()
                                    .attach({
                                        DispatchQueue.main.async {
                                            self.isSearching = true
                                            self.conductor.search(textDebouncer.text)
                                        }
                                    }, at: \.search)
                            }
                        }
                        .frame(height: 48)
                    }
                    .cornerRadius(6.0)
                }
                
                
                #if os(macOS)
                EmptyView()
                    .onChange(of: textDebouncer.query) { value in
                    self.isSearching = true
                    self.conductor.search(value)
                }
                #endif
                
                EmptyView()
                    .onChange(of: conductor.lastQuery) { _ in
                    isSearching = false
                }
                
                if textDebouncer.text.isEmpty == false {
                    Group {
                        HStack(spacing: .layer1) {
                            #if os(iOS)
                            if isSearching {
                                ProgressView()
                                    .padding(.trailing, .layer4)
                            }
                            #else
                            if conductor.lastQuery != textDebouncer.query {
                                ProgressView()
                                    .scaleEffect(0.6)
                            }
                            #endif
                            
                            //TODO: should probably maintain and cancel should actually invoke cancelling search
                            if Device.isMacOS {
                                Button(action: {
                                    GraniteHaptic.light.invoke()
                                    conductor.clean()
                                    
#if os(iOS)
                                    hideKeyboard()
#endif
                                }) {
                                    Text("MISC_CANCEL")
                                        .font(.footnote.bold())
                                        .foregroundColor(.foreground)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.trailing, .layer4)
                            }
                        }
                        .frame(height: Device.isMacOS == false && isSearching ? 48 : nil)
                        //                        .transition(.move(edge: .trailing))
                        //                        .animation(.default)
                    }
                }
            }
        }
    }
    
    func resetView() {
#if canImport(UIKit)
        self.hideKeyboard()
#endif
        conductor.clean()
    }
}
struct StandardLoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                #if os(iOS)
                ProgressView()
                #else
                ProgressView()
                    .scaleEffect(0.6)
                #endif
                Spacer()
            }
            
            Spacer()
        }
    }
}

struct StandardToolbarView: View {
    @GraniteAction<Void> var search
    
    var body: some View {
        Group {
//            Spacer()
            
            Button {
                GraniteHaptic.light.invoke()
                
                #if os(iOS)
                hideKeyboard()
                #endif
            } label : {
                if #available(macOS 13.0, iOS 16.0, *) {
                    Image(systemName: "keyboard.chevron.compact.down.fill")
                        .font(.headline)
                } else {
                    Image(systemName: "chevron.down")
                        .font(.headline)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            Button {
                GraniteHaptic.light.invoke()
                search.perform()
            } label : {
                Text("MISC_SEARCH")
                    .font(.headline.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Color.background.opacity(0.75)
                            .cornerRadius(4)
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

class TextDebouncer : ObservableObject {
    @Published var query = ""
    @Published var text = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        #if os(macOS)
        $text
            .debounce(for: .seconds(1.2), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
                guard trimmedValue.isNotEmpty else { return }
                self?.query = trimmedValue
            } )
            .store(in: &cancellables)
        #endif
    }
}
