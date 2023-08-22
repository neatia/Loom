import Foundation
import SwiftUI
import Granite

final public class GraniteSheetManager : ObservableObject {
    public static var defaultId: String = "granite.sheet.manager.content.main"
    
    var style : GraniteSheetPresentationStyle = .sheet
    
    @Published var models : [String: ContentModel] = [:]
    var detentsMap : [String: [UISheetPresentationController.Detent]] = [:]
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
    
    func detents(id: String = GraniteSheetManager.defaultId) -> [UISheetPresentationController.Detent] {
        return self.detentsMap[id] ?? [.medium(), .large()]
    }
    
    public func present<Content : View>(id: String = GraniteSheetManager.defaultId,
                                        detents: [UISheetPresentationController.Detent] = [.medium(), .large()],
                                        @ViewBuilder content : () -> Content, style : GraniteSheetPresentationStyle = .sheet) {
        self.style = style
        self.detentsMap[id] = detents
        self.models[id] = .init(id: id, content: AnyView(content()))
    }
    
    public func dismiss(id: String = GraniteSheetManager.defaultId) {
        DispatchQueue.main.async { [weak self] in
            self?.detentsMap[id] = nil
            self?.models[id] = nil
            self?.shouldPreventDismissal = false
        }
    }
}
