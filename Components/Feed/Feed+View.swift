import Granite
import GraniteUI
import SwiftUI
import LemmyKit

extension Feed: View {
    var safeAreaTop: CGFloat {
#if os(iOS)
        if #available(iOS 11.0, *),
           let keyWindow = UIApplication.shared.keyWindow {
            return keyWindow.safeAreaInsets.top
        }
#endif
        return 0
    }
    
    public var view: some View {
        VStack(spacing: 0) {
            switch config.state.style {
            case .expanded:
                horizontalLayout
            default:
                verticalLayout
            }
        }
        .addGraniteSheet(modal.sheetManager, background: Color.clear)
        .addGraniteModal(modal.modalManager)
        .graniteNavigationDestinationIf(state.community != nil, trailingItems: {
            communityInfoView
        })
        .background(Color.background)
        .onChange(of: config.state.feedCommunityContext) { context in
            switch context {
            case .viewCommunity(let model):
                self.fetchCommunity(model, reset: true)
            case .viewCommunityView(let model):
                let community = model.community
                self._state.community.wrappedValue = model.community
                self._state.communityView.wrappedValue = model
                self.pager.fetch(force: true)
            default:
                break
            }
        }
        .task {
            pager.hook { page in
                let posts = await Lemmy.posts(state.community,
                                              type: selectedListing,
                                              page: page,
                                              limit: ConfigService.Preferences.pageLimit,
                                              sort: selectedSort,
                                              useBase: true)
                return posts
            }
            
            switch config.state.style {
            case .expanded:
                switch config.state.feedCommunityContext {
                case .viewCommunity(let community):
                    fetchCommunity(community, reset: true)
                case .viewCommunityView(let communityView):
                    fetchCommunity(communityView.community, reset: true)
                default:
                    pager.fetch()
                }
            default:
                if state.community == nil {
                    pager.fetch()
                } else {
                    fetchCommunity(reset: true)
                }
            }
        }
    }
}

//TODO: remove?
struct GaugeProgressStyle: ProgressViewStyle {
    var strokeColor = Color.white
    var strokeWidth = 2.0

    func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0

        return ZStack {
            Circle()
                .trim(from: 0, to: fractionCompleted)
                .stroke(strokeColor, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 25, height: 25)
                .contentShape(Rectangle())
        }
    }
}
