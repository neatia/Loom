import Foundation
import SwiftUI

final public class GraniteSheetManager : ObservableObject {
    public static var defaultId: String = "granite.sheet.manager.content.main"
    
    var style : GraniteSheetPresentationStyle = .sheet
    
    @Published var models : [String: ContentModel] = [:]
    @Published public var shouldPreventDismissal : Bool = false
    
    struct ContentModel {
        let id: String
        let content: AnyView
    }
    
    
    public init() {
        
    }
    
    func hasContent(id: String = GraniteSheetManager.defaultId,
                    with style : GraniteSheetPresentationStyle) -> Binding<Bool> {
        .init(get: {
            self.models[id] != nil && self.style == style
        }, set: { value in
            if value == false {
                self.models[id] = nil
            }
        })
    }
    
    public func present<Content : View>(id: String = GraniteSheetManager.defaultId,
                                        @ViewBuilder content : () -> Content, style : GraniteSheetPresentationStyle = .sheet) {
        self.style = style
        self.models[id] = .init(id: id, content: AnyView(content()))
    }
    
    public func dismiss(id: String = GraniteSheetManager.defaultId) {
        DispatchQueue.main.async { [weak self] in
            self?.models[id] = nil
            self?.shouldPreventDismissal = false
        }
    }
}
