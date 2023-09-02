//
//  SearchConductor.Views.swift
//  Loom
//
//  Created by PEXAVC on 8/9/23.
//

import Foundation
import Granite
import GraniteUI
import SwiftUI
import Combine

struct SearchBar: View {
    @GraniteAction<String> var query
    @GraniteAction<Void> var clean
    
    @Binding var lastQuery: String
    
    var offline: Bool
    init(lastQuery: Binding<String>? = nil, debounceInterval: Double = 1.2) {
        self.offline = lastQuery == nil
        self._lastQuery = lastQuery ?? .constant("")
        self._textDebouncer = .init(wrappedValue: .init(debounceInterval))
    }
    
    @StateObject var textDebouncer: TextDebouncer
    
    @State var isSearching: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                if ((Device.isMacOS && isSearching == false) || (Device.isMacOS == false)) || offline {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .frame(width: 20, height: 20, alignment: .leading)
                            .padding(.leading, .layer4)
                            .foregroundColor(Brand.Colors.grey)
                        

                        
                        #if os(iOS)
                        TextToolView(text: $textDebouncer.text,
                                     kind: .search)
                            .attach({
                                #if os(iOS)
                                guard textDebouncer.text != lastQuery else { return }
                                query.perform(textDebouncer.text)
                                #endif
                            }, at: \.onSubmit)
                            .frame(height: 48)
                            .padding(.top, .layer1)
                        #else
                        TextField("MISC_SEARCH",
                                  text: $textDebouncer.text)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.headline.bold())
                        .autocorrectionDisabled(true)
                        .submitLabel(.search)
                        .frame(height: 48)
                        .onSubmit {
                            #if os(iOS)
                            hideKeyboard()
                            guard textDebouncer.text != lastQuery else { return }
                            isSearching = true
                            query.perform(textDebouncer.text)
                            #endif
                        }
                        #endif
                    }
                    .cornerRadius(6.0)
                }
                
                
                #if os(macOS)
                EmptyView()
                    .onChange(of: textDebouncer.query) { value in
                    if offline == false {
                        self.isSearching = true
                    }
                    query.perform(value)
                }
                #endif
                
                EmptyView()
                    .onChange(of: lastQuery) { _ in
                    isSearching = false
                }
                
                if textDebouncer.text.isEmpty == false {
                    Group {
                        HStack(spacing: .layer1) {
                            #if os(iOS)
                            if isSearching && offline == false {
                                StandardProgressView()
                                    .padding(.trailing, .layer4)
                            }
                            #else
                            if lastQuery != textDebouncer.query && offline == false {
                                StandardProgressView()
                            }
                            #endif
                            
                            //TODO: should probably maintain and cancel should actually invoke cancelling search
                            if offline {
                                Button(action: {
                                    GraniteHaptic.light.invoke()
                                    resetView()
                                    $textDebouncer.text.wrappedValue = ""

                                    UIApplication.hideKeyboard()
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
                    }
                }
            }
        }
    }
    
    func resetView() {
        UIApplication.hideKeyboard()
        clean.perform()
    }
}
struct StandardLoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                StandardProgressView()
                Spacer()
            }
            
            Spacer()
        }
    }
}

struct StandardSearchToolbarView: View {
    @GraniteAction<Void> var search
    
    var body: some View {
        Group {
//            Spacer()
            
            Button {
                GraniteHaptic.light.invoke()
                
                UIApplication.hideKeyboard()
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
    
    init(_ interval: Double = 1.2) {
        #if os(macOS)
        $text
            .debounce(for: .seconds(interval), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
                guard trimmedValue.isNotEmpty else { return }
                self?.query = trimmedValue
            } )
            .store(in: &cancellables)
        #endif
    }
}
