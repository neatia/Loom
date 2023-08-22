import Foundation
import SwiftUI
import Granite

//Compatibility
#if os(macOS)
public struct UISheetPresentationController {
    open class Detent : NSObject {
        enum Identifier {
            case large
            case medium
            case small
        }
        
        
        open class func medium() -> Detent { return Detent() }
        
        
        open class func large() -> Detent { return Detent() }
        
    }
}
#endif

struct GraniteSheetContainerView<Content : View, Background : View> : View {
    
    @EnvironmentObject var manager : GraniteSheetManager
    
    #if os(iOS)
    @State private var selectedDetentIdentifier: UISheetPresentationController.Detent.Identifier? = UISheetPresentationController.Detent.Identifier.medium
    #endif
    
    let id: String
    let content : Content
    let modalManager: GraniteModalManager?
    let background : Background
    
    init(id: String = GraniteSheetManager.defaultId,
         modalManager: GraniteModalManager? = nil,
         content : @autoclosure () -> Content,
         background : @autoclosure () -> Background) {
        self.id = id
        self.modalManager = modalManager
        self.content = content()
        self.background = background()
    }
    
    let pubDidClickInside = Granite.App.Interaction.windowClickedInside.publisher
    
    var body: some View {
#if os(iOS)
        if #available(iOS 14.5, *),
           Device.isiPad == false {
            content
                .fullScreenCover(isPresented: manager.hasContent(with: .cover)) {
                    sheetContent(for: manager.style)
                        .background(FullScreenCoverBackgroundRemovalView())

                }
                .shee(isPresented: manager.hasContent(with: .sheet),
                      presentationStyle:
                        .formSheet(properties:
                                .init(detents: manager.detents(),
                                      selectedDetentIdentifier: $selectedDetentIdentifier,
                                      animatesSelectedDetentIdentifierChange: true))) {
                    
                    sheetContent(for: manager.style)
                        .background(FullScreenCoverBackgroundRemovalView())
                }
        } else {
            content
                .fullScreenCover(isPresented: manager.hasContent(with: .cover)) {
                    sheetContent(for: manager.style)
                        .background(FullScreenCoverBackgroundRemovalView())

                }
                .sheet(isPresented: manager.hasContent(with: .sheet)) {
                    sheetContent(for: manager.style)
                        .background(FullScreenCoverBackgroundRemovalView())
                }
                /*.graniteFullScreenCover(isPresented: manager.hasContent(with: .cover)) {
                    sheetContent(for: manager.style)
                }*/
        }
#else
        content
            .sheet(isPresented: manager.hasContent(id: self.id, with: .sheet)) {
                if let modalManager {
                    sheetContent(for: manager.style)
                        .addGraniteModal(modalManager)
                } else {
                    sheetContent(for: manager.style)
                }
            }
            .graniteNavigation(disable: Device.isExpandedLayout)
#endif
    }
    
    fileprivate func sheetContent(for style : GraniteSheetPresentationStyle) -> some View {
        ZStack {
#if os(iOS)
            background
                .edgesIgnoringSafeArea(.all)
                .zIndex(5)
#endif
            
            if style == .sheet {
                
#if os(iOS)
                manager.models[self.id]?.content
                    .graniteSheetDismissable(shouldPreventDismissal: manager.shouldPreventDismissal)
                    .zIndex(7)
#else
                
                manager.models[self.id]?.content
                    .zIndex(7)
#endif
            }
            else {
                manager.models[self.id]?.content
                    .zIndex(7)
            }
        }
        .onReceive(pubDidClickInside) { _ in
            #if os(macOS)
            manager.dismiss(id: self.id)
            #endif
        }
    }
    
}

#if os(iOS)
extension View {
    
    func transparentNonAnimatingFullScreenCover<Content: View>(isPresented: Binding<Bool>, content: @escaping () -> Content) -> some View {
        modifier(TransparentNonAnimatableFullScreenModifier(isPresented: isPresented, fullScreenContent: content))
    }
    
}

private struct TransparentNonAnimatableFullScreenModifier<FullScreenContent: View>: ViewModifier {
    
    @Binding var isPresented: Bool
    let fullScreenContent: () -> (FullScreenContent)
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { isPresented in
                UIView.setAnimationsEnabled(false)
            }
            .fullScreenCover(isPresented: $isPresented,
                             content: {
                ZStack {
                    fullScreenContent()
                }
                .background(FullScreenCoverBackgroundRemovalView())
                .onAppear {
                    if !UIView.areAnimationsEnabled {
                        UIView.setAnimationsEnabled(true)
                    }
                }
                .onDisappear {
                    if !UIView.areAnimationsEnabled {
                        UIView.setAnimationsEnabled(true)
                    }
                }
            })
    }
}

private struct FullScreenCoverBackgroundRemovalView: UIViewRepresentable {
    
    private class BackgroundRemovalView: UIView {
        
        override func didMoveToWindow() {
            super.didMoveToWindow()
            
            superview?.superview?.backgroundColor = .clear
        }
        
    }
    
    func makeUIView(context: Context) -> UIView {
        return BackgroundRemovalView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
}
#else
private struct FullScreenCoverBackgroundRemovalView: NSViewRepresentable {
    
    private class BackgroundRemovalView: NSView {
        
        override func viewDidMoveToWindow() {
            window?.backgroundColor = .clear
            super.viewDidMoveToWindow()
        }
        
    }
    
    func makeNSView(context: Context) -> NSView {
        return BackgroundRemovalView()
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
    
}
#endif
