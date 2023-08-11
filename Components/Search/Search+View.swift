import Granite
import SwiftUI
import LemmyKit
import GraniteUI

extension Search: View {
    public var view: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack(spacing: .layer4) {
                    VStack {
                        Spacer()
                        Text("TITLE_SEARCH \(community?.name ?? "")")
                            .font(.title.bold())
                    }
                    
                    Spacer()
                    
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
                
                Divider()
            }
            
            if selectedSearch.isFocusedContent {
                SearchScrollView(selectedSearch,
                                 community: community,
                                 sortType: selectedSort,
                                 listingType: selectedListing,
                                 response: $conductor.response,
                                 query: conductor.lastQuery)
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
        .graniteNavigation(backgroundColor: Color.background, disable: Device.isMacOS) {
            Image(systemName: "chevron.backward")
                .renderingMode(.template)
                .font(.title2)
                .frame(width: 24, height: 24)
                .contentShape(Rectangle())
                .offset(x: -2)
        }
        .padding(.top, Device.isExpandedLayout ? .layer3 : .layer2)
        .foregroundColor(.foreground)
        .background(Color.background)
        .task {
            conductor.hook { query in
                await Lemmy.search(query,
                                   type_: selectedSearch,
                                   communityId: nil,
                                   communityName: community?.name,
                                   creatorId: nil,
                                   sort: selectedSort,
                                   listingType: selectedListing,
                                   page: 1,
                                   limit: ConfigService.Preferences.pageLimit)
            }
        }
        .onAppear {
            conductor.startTimer("")
        }
    }
}
