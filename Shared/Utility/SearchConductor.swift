//
//  Search.swift
//  Lemur
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
        
//        $query
//            .debounce(for:  .seconds(1), scheduler: DispatchQueue.main)
//            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
//            .removeDuplicates()
//            .sink { [weak self] value in
////                guard value.isNotEmpty else {
////                    self?.clean()
////                    return
////                }
//                self?.startTimer()
//            }.store(in: &cancellables)
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
        isSearching = true
        searchTimer = Timer.publish(every: 1,
                                    on: .main,
                                    in: .common)
          .autoconnect()
          .sink(receiveValue: { [weak self] (output) in
              self?.searchTimer?.cancel()
              print("[Executing Query] \(query)")
              self?.search(query)
          })
    }
    
    func search(_ query: String) {
        let q = query
        searchTimer?.cancel()
        searchTimer = nil
        self.task?.cancel()
        self.task = Task.detached(priority: .background) { [weak self] in
            let response = await self?.handler?(q)
            DispatchQueue.main.async { [weak self] in
                GraniteHaptic.light.invoke()
                self?.response = response
                self?.isSearching = false
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
    
    @State var query: String = ""
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .leading)
                        .padding(.leading, .layer4)
                        .foregroundColor(Brand.Colors.grey)
                    
                    TextField("MISC_SEARCH",
                              text: $query)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.headline.bold())
                    .autocorrectionDisabled(true)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            StandardToolbarView()
                                .attach({
                                    conductor.search(query)
                                }, at: \.search)
                        }
                    }
                    .onTapGesture {
                        
                    }
                    .frame(height: 48)
                }
                .cornerRadius(6.0)
                
                #if os(macOS)
                EmptyView()
                    .onChange(of: query) { value in
                    let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard trimmedValue.isNotEmpty else { return }
                    conductor.startTimer(trimmedValue)
                }
                #endif
                
                if query.isEmpty == false {
                    Group {
                        Button(action: {
                            GraniteHaptic.light.invoke()
                            conductor.clean()
                            
                            #if os(iOS)
                            hideKeyboard()
                            #endif
                            
                            query = ""
                        }) {
                            Text("MISC_CANCEL")
                                .font(.footnote.bold())
                                .foregroundColor(.foreground)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.trailing, .layer4)
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
