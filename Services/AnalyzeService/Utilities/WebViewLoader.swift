import SwiftUI
import WebKit
import Granite

class WKDelegate: NSObject, WKNavigationDelegate {
    
//    private var completion: ((String) -> Void)?
//    init(_ completion: @escaping (String) -> Void) {
//        self.completion = completion
//    }
    
    override init() {}
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("End loading")
//        webView.evaluateJavaScript("document.body.innerHTML", completionHandler: { [weak self] result, error in
//
//            if let html = result as? String {
//                self?.completion?(html)
//                self?.completion = nil
//            }
//        })
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        switch navigationAction.navigationType {
        case .reload:
            return .cancel
        default:
            return .allow
            
        }
    }
}

class WKMessageDelegate: NSObject, WKScriptMessageHandler {
    
    public var completion: ((String) -> Void)?
    override init() {}
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "didGetHTML" {
            if let html = message.body as? String {
                completion?(html)
                completion = nil
            }
        }
    }
}

class WebViewLoader: ObservableObject, Equatable {
    static func == (lhs: WebViewLoader, rhs: WebViewLoader) -> Bool {
        lhs.url == rhs.url
    }
    
    @Published var webViewStore: WebViewStore
    
    public enum CodingKeys : CodingKey {
        case url
    }
    
    private var webView: WKWebView?
    private var url: URL?
    private var delegate: WKDelegate?
    private var mdelegate: WKMessageDelegate
    
    init() {
        let userContentController = WKUserContentController()
        let configuration = WKWebViewConfiguration()
        
        let javascriptString: String = """
        webkit.messageHandlers.didGetHTML.postMessage(document.documentElement.outerHTML.toString());
        """
        
        let script = WKUserScript(source: javascriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        mdelegate = .init()
        
        userContentController.addUserScript(script)
        userContentController.add(mdelegate, contentWorld: .page, name: "didGetHTML")
        userContentController.add(mdelegate, contentWorld: .page, name: "error")
        
        configuration.userContentController = userContentController
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webViewStore = WebViewStore(webView: webView)
    }
    
    func fetch(_ urlString: String, _ completion: @escaping (String) -> Void) {
        guard let url = URL(string: urlString) else { return }
        mdelegate.completion = { value in
            self.webView?.stopLoading()
            completion(value)
        }
        webViewStore.webView.load(.init(url: url))
//        delegate = WKDelegate(completion)
//        webView = WKWebView(frame: .zero)
//        webView?.navigationDelegate = delegate
//
//        print("[WebViewLoader] loading: \(urlStr)")
//        url = URL(string: urlStr)
//
//        loadUrl()
    }
    
    func loadUrl() {
        guard let url = url else { return }
        webView?.load(URLRequest(url: url))
    }
}
