import Granite
import Foundation

extension AnalyzeService {
    struct Load: GraniteReducer {
        typealias Center = AnalyzeService.Center
        
        struct Meta: GranitePayload {
            var url: String
        }
        
        @Payload var meta: Meta?
        @Event var loaded: Loaded.Reducer
        
        func reduce(state: inout Center.State) {
            guard let urlString = meta?.url else { return }
            
            state.status += .loading
            
            var loader: WebViewLoader = .init()
            loader.fetch(urlString) { html in
                loaded.send(Loaded.Meta.init(html: html))
            }
        }
    }
    
    struct Loaded: GraniteReducer {
        typealias Center = AnalyzeService.Center
        
        struct Meta: GranitePayload {
            let html: String
        }
        
        @Payload var meta: Meta?
        
        @Event(.after) var summarize: Summarize.Reducer
        
        func reduce(state: inout Center.State) {
            guard let html = meta?.html else { return }
            
            state.source = .init(html)
            
            state.status -= .loading
            state.status += .summarizing
        }
        
        var thread: DispatchQueue? {
            .global(qos: .background)
        }
    }
}
