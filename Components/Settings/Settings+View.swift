import Granite
import GraniteUI
import SwiftUI
import WebKit
import Foundation

extension Settings: View {
    var aboutPageLinkString: String {
        ""
    }
    
    public var view: some View {
        VStack(spacing: 0) {
            HStack(spacing: .layer4) {
                VStack {
                    Spacer()
                    Text("TITLE_SETTINGS")
                        .font(.title.bold())
                }
                
                Spacer()
            }
            .frame(height: 36)
            .padding(.bottom, .layer4)
            .padding(.leading, .layer4)
            .padding(.trailing, .layer4)
            
            Divider()
            
            ScrollView(showsIndicators: false) {
                
//                VStack(alignment: .leading, spacing: 0) {
//                    Spacer()
//                    HStack {
//                        Text("TITLE_FEED")
//                            .font(.title2.bold())
//
//                        Spacer()
//                    }
//
//                    HStack {
//                        VStack(alignment: .leading, spacing: 0) {
//                            Toggle(isOn: config._state.linkPreviewMetaData) {
//                                Text("SETTINGS_FEED_LINK_DETAILS")
//                                    .font(.headline)
//                                    .offset(x: 0, y: Device.isMacOS ? -1 : 0)
//                            }
//                        }
//                        .padding(.vertical, .layer3)
//
//
//                        #if os(macOS)
//                        Spacer()
//                        #endif
//                    }
//                }
//                .padding(.top, .layer4)
//                .padding(.horizontal, .layer4)
                
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    HStack {
                        Group {
                            Text("MISC_IPFS")
                                .font(.title2.bold())+Text(" (Infura)")
                                .font(.title2.bold())
                        }
                            .addInfoIcon(text: "IPFS_INFO_TEMP", modal)
                        
                        Spacer()
                    }
                    .padding(.top, .layer4)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Toggle(isOn: config._state.enableIPFS) {
                                Text("SETTINGS_IPFS_ENABLE")
                                    .font(.headline)
                                    .offset(x: 0, y: Device.isMacOS ? -1 : 0)
                            }
                        }.padding(.vertical, .layer3)
                        
                        #if os(macOS)
                        Spacer()
                        #endif
                    }
                    
                    HStack(spacing: .layer2) {
                        Group {
                            if config.state.isIPFSAvailable {
                                Image(systemName: "checkmark.circle")
                                    .font(.headline)
                                Text("IPFS_STATUS_ONLINE")
                                    .font(.headline.bold())
                            } else {
                                Image(systemName: "xmark.circle")
                                    .font(.headline.bold())
                                Text("IPFS_STATUS_OFFLINE")
                                    .font(.headline.bold())
                            }
                        }
                        .foregroundColor((config.state.isIPFSAvailable ? Color.green : Color.red).opacity(0.8))
                        
                        #if os(iOS)
                        Spacer()
                        #endif
                        
                        Button {
                            GraniteHaptic.light.invoke()
                            setIPFSProperties()
                        } label: {
                            Text("MISC_EDIT")
                                .font(.headline.bold())
                                .foregroundColor(.foreground)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Color.background.opacity(0.75)
                                        .cornerRadius(4)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.leading, .layer3)
                        
                        #if os(macOS)
                        Spacer()
                        #endif
                    }
                    .padding(.bottom, .layer2)
                    
                    #if os(macOS)
                    Spacer()
                    #endif
                }
                .padding(.horizontal, .layer4)
                
                if isTabSelected == true {
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer()
                        HStack {
                            Text("TITLE_GENERAL")
                                .font(.title2.bold())
                            
                            Spacer()
                        }
                    }
                    .padding(.top, .layer4)
                    .padding(.horizontal, .layer4)
                    ProfileSettingsView(showProfileSettings: false,
                                        modal: modal)
                }
                
                DebugSettingsView()
                    .graniteEvent(config.center.restart)
                
                Spacer()
                    .frame(height: 80)
                
                
                HStack(spacing: 4) {
                    Text("TITLE_OPEN_SOURCE")
                        .font(Fonts.live(.footnote, .regular))
                        .foregroundColor(.accentColor)
                        .onTapGesture {
                            if let url = URL(string: "https://github.com/neatia/Loom") {
                                openURL(url)
                            }
                        }
                    
                //TODO: For AppStore Release
//                    Text("MISC_PRIVACY_POLICY")
//                        .font(Fonts.live(.footnote, .regular))
//                        .foregroundColor(.accentColor)
//                        .onTapGesture {
////                            if let url = URL(string: "") {
////                                openURL(url)
////                            }
//                        }
//
//                    Text("//")
//                        .font(Fonts.live(.footnote, .regular))
//                        .foregroundColor(Brand.Colors.white)
//
//
//                    Text("MISC_TERMS_OF_USE")
//                        .font(Fonts.live(.footnote, .regular))
//                        .foregroundColor(.accentColor)
//                        .onTapGesture {
////                            if let url = URL(string: "") {
////                                openURL(url)
////                            }
//                        }
//
//                    Spacer()
                    #if os(macOS)
                    Spacer()
                    #endif
                }
                .frame(maxWidth: .infinity)
                .padding(.top, .layer4)
                .padding(.bottom, .layer2)
                .padding(.horizontal, .layer4)
                
//                HStack {
//                    Text("MISC_COPYRIGHT")
//                        .font(Fonts.live(.caption2, .regular))+Text(" Stoic Collective, LLC. \u{00A9} \(Calendar.current.component(.year, from: Date.now).asString.replacingOccurrences(of: ",", with: ""))")
//                        .font(Fonts.live(.caption2, .regular))
//
//                    Spacer()
//                }
//                .padding(.horizontal, .layer4)
//                .padding(.bottom, .layer5)
//                .foregroundColor(.foreground)
            }
        }
        .padding(.top, ContainerConfig.generalViewTopPadding)
        .addGraniteSheet(modal.sheetManager,
                         modalManager: modal.modalSheetManager,
                         background: Color.clear)
        .addGraniteModal(modal.modalManager)
    }
}

public enum WebViewAction: Equatable {
    case idle,
         load(URLRequest),
         loadHTML(String),
         reload,
         goBack,
         goForward,
         evaluateJS(String, (Result<Any?, Error>) -> Void)
    
    
    public static func == (lhs: WebViewAction, rhs: WebViewAction) -> Bool {
        if case .idle = lhs,
           case .idle = rhs {
            return true
        }
        if case let .load(requestLHS) = lhs,
           case let .load(requestRHS) = rhs {
            return requestLHS == requestRHS
        }
        if case let .loadHTML(htmlLHS) = lhs,
           case let .loadHTML(htmlRHS) = rhs {
            return htmlLHS == htmlRHS
        }
        if case .reload = lhs,
           case .reload = rhs {
            return true
        }
        if case .goBack = lhs,
           case .goBack = rhs {
            return true
        }
        if case .goForward = lhs,
           case .goForward = rhs {
            return true
        }
        if case let .evaluateJS(commandLHS, _) = lhs,
           case let .evaluateJS(commandRHS, _) = rhs {
            return commandLHS == commandRHS
        }
        return false
    }
}

public struct WebViewState: Equatable {
    public internal(set) var isLoading: Bool
    public internal(set) var pageURL: String?
    public internal(set) var pageTitle: String?
    public internal(set) var pageHTML: String?
    public internal(set) var error: Error?
    public internal(set) var canGoBack: Bool
    public internal(set) var canGoForward: Bool
    
    public static let empty = WebViewState(isLoading: false,
                                           pageURL: nil,
                                           pageTitle: nil,
                                           pageHTML: nil,
                                           error: nil,
                                           canGoBack: false,
                                           canGoForward: false)
    
    public static func == (lhs: WebViewState, rhs: WebViewState) -> Bool {
        lhs.isLoading == rhs.isLoading
            && lhs.pageURL == rhs.pageURL
            && lhs.pageTitle == rhs.pageTitle
            && lhs.pageHTML == rhs.pageHTML
            && lhs.error?.localizedDescription == rhs.error?.localizedDescription
            && lhs.canGoBack == rhs.canGoBack
            && lhs.canGoForward == rhs.canGoForward
    }
}

public class WebViewCoordinator: NSObject {
    private let webView: GraniteWebView
    var actionInProgress = false
    
    init(webView: GraniteWebView) {
        self.webView = webView
    }
    
    func setLoading(_ isLoading: Bool,
                    canGoBack: Bool? = nil,
                    canGoForward: Bool? = nil,
                    error: Error? = nil) {
        var newState =  webView.state
        newState.isLoading = isLoading
        if let canGoBack = canGoBack {
            newState.canGoBack = canGoBack
        }
        if let canGoForward = canGoForward {
            newState.canGoForward = canGoForward
        }
        if let error = error {
            newState.error = error
        }
        webView.state = newState
        webView.action = .idle
        actionInProgress = false
    }
}

extension WebViewCoordinator: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      setLoading(false,
                 canGoBack: webView.canGoBack,
                 canGoForward: webView.canGoForward)
        
        webView.evaluateJavaScript("document.title") { (response, error) in
            if let title = response as? String {
                var newState = self.webView.state
                newState.pageTitle = title
                self.webView.state = newState
            }
        }
      
        webView.evaluateJavaScript("document.URL.toString()") { (response, error) in
            if let url = response as? String {
                var newState = self.webView.state
                newState.pageURL = url
                self.webView.state = newState
            }
        }
        
        if self.webView.htmlInState {
            webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (response, error) in
                if let html = response as? String {
                    var newState = self.webView.state
                    newState.pageHTML = html
                    self.webView.state = newState
                }
            }
        }
    }
    
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        setLoading(false)
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        setLoading(false, error: error)
    }
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        setLoading(true)
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
      setLoading(true,
                 canGoBack: webView.canGoBack,
                 canGoForward: webView.canGoForward)
    }
    
    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let host = navigationAction.request.url?.host {
            if self.webView.restrictedPages?.first(where: { host.contains($0) }) != nil {
                decisionHandler(.cancel)
                setLoading(false)
                return
            }
        }
        if let url = navigationAction.request.url,
           let scheme = url.scheme,
           let schemeHandler = self.webView.schemeHandlers[scheme] {
            schemeHandler(url)
            decisionHandler(.cancel)
            return
        }
        
        switch navigationAction.request.url?.absoluteString {
        case "about:srcdoc":
            decisionHandler(.cancel)
            setLoading(false)
        case "about:blank":
            decisionHandler(.cancel)
            setLoading(false)
        default:
            decisionHandler(.allow)
        }
    }
}

extension WebViewCoordinator: WKUIDelegate {
  public func webView(_ webView: WKWebView,
                      createWebViewWith configuration: WKWebViewConfiguration,
                      for navigationAction: WKNavigationAction,
                      windowFeatures: WKWindowFeatures) -> WKWebView? {
    if navigationAction.targetFrame == nil {
      webView.load(navigationAction.request)
    }
    return nil
  }
}

public struct WebViewConfig {
    public static let `default` = WebViewConfig()
    
    public let javaScriptEnabled: Bool
    public let allowsBackForwardNavigationGestures: Bool
    public let allowsInlineMediaPlayback: Bool
    public let mediaTypesRequiringUserActionForPlayback: WKAudiovisualMediaTypes
    public let isScrollEnabled: Bool
    public let isOpaque: Bool
    public let backgroundColor: Color
    
    public init(javaScriptEnabled: Bool = true,
                allowsBackForwardNavigationGestures: Bool = true,
                allowsInlineMediaPlayback: Bool = true,
                mediaTypesRequiringUserActionForPlayback: WKAudiovisualMediaTypes = [],
                isScrollEnabled: Bool = true,
                isOpaque: Bool = true,
                backgroundColor: Color = .clear) {
        self.javaScriptEnabled = javaScriptEnabled
        self.allowsBackForwardNavigationGestures = allowsBackForwardNavigationGestures
        self.allowsInlineMediaPlayback = allowsInlineMediaPlayback
        self.mediaTypesRequiringUserActionForPlayback = mediaTypesRequiringUserActionForPlayback
        self.isScrollEnabled = isScrollEnabled
        self.isOpaque = isOpaque
        self.backgroundColor = backgroundColor
    }
}

#if os(iOS)
public struct GraniteWebView: UIViewRepresentable {
    let config: WebViewConfig
    @Binding var action: WebViewAction
    @Binding var state: WebViewState
    let restrictedPages: [String]?
    let htmlInState: Bool
    let schemeHandlers: [String: (URL) -> Void]
    
    public init(config: WebViewConfig = .default,
                action: Binding<WebViewAction>,
                state: Binding<WebViewState>,
                restrictedPages: [String]? = nil,
                htmlInState: Bool = false,
                schemeHandlers: [String: (URL) -> Void] = [:]) {
        self.config = config
        _action = action
        _state = state
        self.restrictedPages = restrictedPages
        self.htmlInState = htmlInState
        self.schemeHandlers = schemeHandlers
    }
    
    public func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(webView: self)
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = config.javaScriptEnabled
        
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = config.allowsInlineMediaPlayback
        configuration.mediaTypesRequiringUserActionForPlayback = config.mediaTypesRequiringUserActionForPlayback
        configuration.preferences = preferences
        
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = config.allowsBackForwardNavigationGestures
        webView.scrollView.isScrollEnabled = config.isScrollEnabled
        webView.isOpaque = config.isOpaque
        if #available(iOS 14.0, *) {
            webView.backgroundColor = UIColor(config.backgroundColor)
        } else {
            webView.backgroundColor = .clear
        }
        
        switch action {
        case .load(let request):
            webView.load(request)
        default:
            break
        }
        
        return webView
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        if action == .idle || context.coordinator.actionInProgress {
            return
        }
        context.coordinator.actionInProgress = true
        switch action {
        case .idle:
            break
        case .load(let request):
            uiView.load(request)
        case .loadHTML(let pageHTML):
            uiView.loadHTMLString(pageHTML, baseURL: nil)
        case .reload:
            uiView.reload()
        case .goBack:
            uiView.goBack()
        case .goForward:
            uiView.goForward()
        case .evaluateJS(let command, let callback):
            uiView.evaluateJavaScript(command) { result, error in
                if let error = error {
                    callback(.failure(error))
                } else {
                    callback(.success(result))
                }
            }
        }
    }
}
#endif

#if os(macOS)
public struct GraniteWebView: NSViewRepresentable {
    let config: WebViewConfig
    @Binding var action: WebViewAction
    @Binding var state: WebViewState
    let restrictedPages: [String]?
    let htmlInState: Bool
    let schemeHandlers: [String: (URL) -> Void]
    
    public init(config: WebViewConfig = .default,
                action: Binding<WebViewAction>,
                state: Binding<WebViewState>,
                restrictedPages: [String]? = nil,
                htmlInState: Bool = false,
                schemeHandlers: [String: (URL) -> Void] = [:]) {
        self.config = config
        _action = action
        _state = state
        self.restrictedPages = restrictedPages
        self.htmlInState = htmlInState
        self.schemeHandlers = schemeHandlers
    }
    
    public func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(webView: self)
    }
    
    public func makeNSView(context: Context) -> WKWebView {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = config.javaScriptEnabled
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = config.allowsBackForwardNavigationGestures
        
        switch action {
        case .load(let request):
            webView.load(request)
        default:
            break
        }
        
        return webView
    }
    
    public func updateNSView(_ uiView: WKWebView, context: Context) {
        if action == .idle {
            return
        }
        switch action {
        case .idle:
            break
        case .load(let request):
            uiView.load(request)
        case .loadHTML(let html):
            uiView.loadHTMLString(html, baseURL: nil)
        case .reload:
            uiView.reload()
        case .goBack:
            uiView.goBack()
        case .goForward:
            uiView.goForward()
        case .evaluateJS(let command, let callback):
            uiView.evaluateJavaScript(command) { result, error in
                if let error = error {
                    callback(.failure(error))
                } else {
                    callback(.success(result))
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            action = .idle
        }
    }
}
#endif
