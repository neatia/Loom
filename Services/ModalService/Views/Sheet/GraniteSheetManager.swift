import Foundation
import SwiftUI
import Granite

final public class GraniteSheetManager : ObservableObject {
    public static var defaultId: String = "granite.sheet.manager.content.main"
    
    var style : GraniteSheetPresentationStyle = .sheet
    
    @Published var models : [String: ContentModel] = [:]
    var detentsMap : [String: [Detent]] = [:]
    @Published public var shouldPreventDismissal : Bool = false
    
    struct ContentModel {
        let id: String
        let content: AnyView
    }
    
    var hasContent: Bool {
        models.isEmpty == false
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
    
    func detents(id: String = GraniteSheetManager.defaultId) -> [Detent] {
        return self.detentsMap[id] ?? [.medium, .large]
    }
    
    @MainActor
    public func present<Content : View>(id: String = GraniteSheetManager.defaultId,
                                        detents: [Detent] = [.medium, .large],
                                        @ViewBuilder content : () -> Content, style : GraniteSheetPresentationStyle = .sheet) {
        self.style = style
        self.detentsMap[id] = detents
        
        if Device.isIPhone == false {
            self.models[id] = .init(id: id,
                                    content: AnyView(content()
                                        .graniteNavigation(backgroundColor: Color.clear)))
        } else {
            withAnimation(.easeIn.speed(1.2)) {
                self.models[id] = .init(id: id,
                                        content: AnyView(content()
                                            .graniteNavigation(backgroundColor: Color.clear)))
            }
        }
    }
    
    public func dismiss(id: String = GraniteSheetManager.defaultId) {
        DispatchQueue.main.async { [weak self] in
            if Device.isiPad {
                self?.detentsMap[id] = nil
                self?.models[id] = nil
                self?.shouldPreventDismissal = false
            } else {
                UIApplication.hideKeyboard()
                withAnimation(.easeOut.speed(1.2)) {
                    self?.detentsMap[id] = nil
                    self?.models[id] = nil
                    self?.shouldPreventDismissal = false
                }
            }
        }
    }
    
    public func destroy() {
        DispatchQueue.main.async { [weak self] in
            self?.detentsMap = [:]
            self?.models = [:]
            self?.shouldPreventDismissal = false
        }
    }
}
