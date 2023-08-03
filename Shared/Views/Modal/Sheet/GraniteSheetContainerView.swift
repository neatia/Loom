import Foundation
import SwiftUI

struct GraniteSheetContainerView<Content : View, Background : View> : View {
    
    @EnvironmentObject var manager : GraniteSheetManager
    
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
    
    let pubDidClickInside = NotificationCenter.default
            .publisher(for: NSNotification.Name("granite.window.ClickedInside"))
    
    var body: some View {
#if os(iOS)
        if #available(iOS 14.5, *) {
            content
                .fullScreenCover(isPresented: manager.hasContent(with: .cover)) {
                    sheetContent(for: manager.style)
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
                }
                .sheet(isPresented: manager.hasContent(with: .sheet)) {
                    sheetContent(for: manager.style)
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
                }
        } else if #available(iOS 14.0, *) {
            content
                .fullScreenCover(isPresented: manager.hasContent(with: .cover)) {
                    sheetContent(for: manager.style)
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
                }
                .overlay (
                    EmptyView()
                        .sheet(isPresented: manager.hasContent(with: .sheet)) {
                            sheetContent(for: manager.style)
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
                        }
                )
        } else {
            content
                .sheet(isPresented: manager.hasContent(with: .sheet)) {
                    sheetContent(for: manager.style)
                }
                .graniteFullScreenCover(isPresented: manager.hasContent(with: .cover)) {
                    sheetContent(for: manager.style)
                }
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
            super.viewDidMoveToWindow()
            superview?.superview?.layer?.backgroundColor = .black
        }
        
    }
    
    func makeNSView(context: Context) -> NSView {
        return BackgroundRemovalView()
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
    
}
#endif
