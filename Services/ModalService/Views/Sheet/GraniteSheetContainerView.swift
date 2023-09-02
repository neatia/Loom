import Foundation
import SwiftUI
import Granite
import GraniteUI

public enum Detent: Hashable, CaseIterable {
    case large
    case medium
    //case small
    case inactive
    
    var height: CGFloat {
        switch self {
        case .large:
            #if os(macOS)
            return ContainerConfig.iPhoneScreenHeight - 100
            #else
            return UIScreen.main.bounds.height - 100
            #endif
        case .medium:
            return 360
//        case .small:
//            return 360
        case .inactive:
            return 100
        }
    }
}


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
    
    let pubDidClickInside = Granite.App.Interaction.windowClickedInside.publisher
    
    var body: some View {
#if os(iOS)
        if #available(iOS 14.5, *),
           Device.isiPad == false {
            content
                .fullScreenCover(isPresented: manager.hasContent(id: self.id, with: .cover)) {
                    sheetContent(for: manager.style)
                        .background(FullScreenCoverBackgroundRemovalView())

                }
                .showDrawer(manager.hasContent(id: self.id, with: .sheet),
                            manager.detents(id: self.id)) {
                    sheetContent(for: manager.style)
                }
        } else {
            content
                .fullScreenCover(isPresented: manager.hasContent(id: self.id, with: .cover)) {
                    sheetContent(for: manager.style)
                        .background(FullScreenCoverBackgroundRemovalView())

                }
                .sheet(isPresented: manager.hasContent(id: self.id, with: .sheet)) {
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

fileprivate extension View {
    func showDrawer<Content: View>(_ condition: Binding<Bool>,
                                   _ detents: [Detent] = [.medium],
                    @ViewBuilder _ content: () -> Content) -> some View {

        return self.overlayIf(condition.wrappedValue, alignment: .top) {
            Group {
                #if os(iOS)
                Drawer(startingHeight: detents.first?.height ?? Detent.medium.height, keyboardAware: true) {
                    ZStack(alignment: .top) {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(Color.alternateSecondaryBackground)
                            .shadow(radius: 50)
                        
                        VStack(alignment: .center, spacing: 0) {
                            
                            HStack(spacing: 0) {
                                Button {
                                    GraniteHaptic.light.invoke()
                                    withAnimation(.easeOut.speed(1.2)) {
                                        condition.wrappedValue = false
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.foreground)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.top, .layer4)
                                .padding(.leading, .layer4)
                                
                                Spacer()
                                
                                RoundedRectangle(cornerRadius: 8)
                                    .frame(width: 42, height: 6)
                                    .foregroundColor(Color.gray)
                                    .padding(.top, .layer4)
                                
                                Spacer()
                                //centering purposes
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.foreground)
                                    .opacity(0.0)
                                    .padding(.trailing, .layer4)
                            }
                            
                            Divider()
                                .padding(.top, .layer4)
                            
                            content()
                                .adaptsToKeyboard(safeAreaAware: true)
                        }
                        .frame(height: Detent.large.height)
                    }
                }
                .rest(at: .constant(Detent.allCases.map { $0.height }))
                .impact(.light)
                .edgesIgnoringSafeArea(.vertical)
                .transition(.move(edge: .bottom))
                #endif
            }
        }
    }
}
