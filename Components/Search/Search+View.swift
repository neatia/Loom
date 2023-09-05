import Granite
import SwiftUI
import GraniteUI
import FederationKit

extension Search: View {
    public var view: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack(spacing: .layer4) {
                    
                        HStack(spacing: .layer2) {
                            VStack {
                                Spacer()
                                Text("TITLE_SEARCH \(community?.name ?? "")")
                                    .font(.title.bold())
                            }
                            
                            Menu {
                                ForEach(0..<state.searchType.count) { index in
                                    Button {
                                        GraniteHaptic.light.invoke()
                                        _state.selectedSearchType.wrappedValue = index
                                    } label: {
                                        Text(state.searchType[index].displayString)
                                        Image(systemName: "arrow.down.right.circle")
                                    }
                                }
                            } label: {
                                VStack {
                                    //this VStack setup is resolving alignment issues
                                    Spacer()
                                    Text(selectedSearch.displayString)
                                        .font(.title3.bold())
                                        //nitpick
                                        .padding(.top, 5)
                                }
                            }
                            .menuStyle(BorderlessButtonMenuStyle())
                            .frame(maxWidth: Device.isMacOS ? 80 : nil)
                            .foregroundColor(Device.isMacOS ? .foreground : .accentColor)
                            .id(state.selectedSearchType)//Menus have odd interactions on iOS
                        }
                    
                    Spacer()
                    
                    if isModal {
                        VStack {
                            Spacer()
                            
                            Button {
                                GraniteHaptic.light.invoke()
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Image(systemName: Device.isMacOS ? "xmark" : "chevron.down")
                                    .renderingMode(.template)
                                    .font(.title2)
                                    .frame(width: 24, height: 24)
                                    .contentShape(Rectangle())
                                    .foregroundColor(.foreground)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.bottom, 2)
                        }
                    }
                }
                .frame(height: 36)
                .padding(.bottom, .layer4)
                .padding(.leading, .layer4)
                .padding(.trailing, .layer4)
                
                Divider()
                
                headerMenuView
                    .frame(height: 48)
                    .padding(.leading, .layer4)
                    .padding(.trailing, .layer4)
                
                Divider()
                
                SearchBar(lastQuery: $conductor.lastQuery)
                    .attach({ query in
                        conductor.search(query)
                    }, at: \.query)
                    .attach({
                        conductor.clean()
                    }, at: \.clean)
                    .ignoresSafeArea(.keyboard)
                
                Divider()
            }
            .ignoresSafeArea(.keyboard)
            
            //GraniteTab could supply a feature that removes views from the hierarchy like this
            //performance seems to get hurt when switching between tabs from search
            if selectedSearch.isFocusedContent {
                SearchScrollView(selectedSearch,
                                 community: community,
                                 sortType: selectedSort,
                                 listingType: selectedListing,
                                 response: $conductor.response,
                                 query: $conductor.lastQuery)
                .background(Color.alternateBackground)
            } else if conductor.isSearching && conductor.isEmpty {
                StandardLoadingView()
            } else if let response = conductor.response {
                SearchAllView(model: response)
                    .background(Color.alternateBackground)
            } else {
                Spacer()
            }
        }
        .padding(.top, isModal ? (Device.isExpandedLayout ? .layer3 : .layer2) : ContainerConfig.generalViewTopPadding)
        .foregroundColor(.foreground)
        .background(Color.background)
        .task {
            conductor.hook { query in
                await Federation.search(query,
                                        type_: selectedSearch,
                                        communityId: nil,
                                        communityName: community?.name,
                                        creatorId: nil,
                                        sort: selectedSort,
                                        listingType: selectedListing,
                                        page: 1,
                                        limit: ConfigService.Preferences.pageLimit)
            }
            
            guard conductor.response == nil else { return }
            
            //Prevent too many calls on startup
            //maybe boot logic can host a "call loop" for initial
            //network models
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                conductor.startTimer("")
            }
        }
    }
}
