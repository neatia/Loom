#if os(iOS)
import Foundation
import SwiftUI
 
struct AppBlurBackground : UIViewRepresentable {
    
    class IntensityVisualEffectView: UIVisualEffectView {
        
        var observer : NSObjectProtocol? = nil
        
        // MARK: Private
        var animator: UIViewPropertyAnimator!
        
        init(effect: UIVisualEffect, intensity: CGFloat) {
            super.init(effect: nil)
            animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [unowned self] in self.effect = effect }
            animator.fractionComplete = intensity
            
            observer = NotificationCenter.default.addObserver(forName: UIScene.didActivateNotification,
                                                              object: nil,
                                                              queue: .main) { [weak self] notification in
                self?.animator.stopAnimation(true)
                
                self?.animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [unowned self] in
                    self?.effect = effect
                }
                
                self?.animator.fractionComplete = intensity
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError()
        }
        
        deinit {
            if let observer = observer {
                NotificationCenter.default.removeObserver(observer)
            }
        }

    }
    
    let blurStyle : UIBlurEffect.Style
    let blurIntensity : CGFloat
    var whiteColorIntensity : CGFloat = 0.05

    func makeUIView(context: Context) -> IntensityVisualEffectView {
        let view = IntensityVisualEffectView(effect: UIBlurEffect(style: blurStyle),
                                             intensity: blurIntensity)
        
        let overlayView = UIView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.backgroundColor = .white.withAlphaComponent(whiteColorIntensity)
        view.contentView.addSubview(overlayView)
        
        overlayView.leftAnchor.constraint(equalTo: view.contentView.leftAnchor).isActive = true
        overlayView.topAnchor.constraint(equalTo: view.contentView.topAnchor).isActive = true
        overlayView.rightAnchor.constraint(equalTo: view.contentView.rightAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: view.contentView.bottomAnchor).isActive = true
        
        return view
    }
    
    func updateUIView(_ uiView: IntensityVisualEffectView, context: Context) {
        if blurIntensity != uiView.animator.fractionComplete {
            uiView.animator.fractionComplete = blurIntensity
        }
    }
    
}

extension AppBlurBackground {
    
    static var tabBar : AppBlurBackground {
        .init(blurStyle: .systemThinMaterialLight,
              blurIntensity: 0.35)
    }
    
    static var banner : AppBlurBackground {
        .init(blurStyle: .systemThinMaterialLight,
              blurIntensity: 0.17)
    }
    
    static var modal : AppBlurBackground {
        .init(blurStyle: .systemThinMaterialLight,
              blurIntensity: 0.6,
              whiteColorIntensity: 0.0)
    }
    
    static var button : AppBlurBackground {
        .init(blurStyle: .systemThinMaterialLight,
              blurIntensity: 0.245)
    }
    
    static var toast : AppBlurBackground {
        .init(blurStyle: .systemThinMaterialLight,
              blurIntensity: 0.7)
    }
    
    static var alert : AppBlurBackground {
        .init(blurStyle: .systemThinMaterialLight,
              blurIntensity: 0.9,
              whiteColorIntensity: 0.0)
    }
    
}

struct AppBlurView<Content>: View where Content: View {
    
    let size: CGSize
    let padding: EdgeInsets
    let cornerRadius: CGFloat
    var tintColor: Color
    let content: () -> Content

    init(size: CGSize,
         padding: EdgeInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16),
         cornerRadius: CGFloat = 6.0,
         tintColor: Color = .tertiaryBackground.opacity(0.5),
         @ViewBuilder content: @escaping () -> Content) {
        self.size = size
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.tintColor = tintColor
        self.content = content
    }

    var body: some View {
        content()
            .frame(minWidth: size.width)
            .frame(height: size.height)
            .background(AppBlurBackground.modal
                .overlay(tintColor)
                .cornerRadius(cornerRadius))
    }
}
#else

import Foundation
import SwiftUI

//MARK: Visual Effect

struct VisualEffectMaterialKey: EnvironmentKey {
    typealias Value = NSVisualEffectView.Material?
    static var defaultValue: Value = nil
}

struct VisualEffectBlendingKey: EnvironmentKey {
    typealias Value = NSVisualEffectView.BlendingMode?
    static var defaultValue: Value = nil
}

struct VisualEffectEmphasizedKey: EnvironmentKey {
    typealias Value = Bool?
    static var defaultValue: Bool? = nil
}

extension EnvironmentValues {
    var visualEffectMaterial: NSVisualEffectView.Material? {
        get { self[VisualEffectMaterialKey.self] }
        set { self[VisualEffectMaterialKey.self] = newValue }
    }
    
    var visualEffectBlending: NSVisualEffectView.BlendingMode? {
        get { self[VisualEffectBlendingKey.self] }
        set { self[VisualEffectBlendingKey.self] = newValue }
    }
    
    var visualEffectEmphasized: Bool? {
        get { self[VisualEffectEmphasizedKey.self] }
        set { self[VisualEffectEmphasizedKey.self] = newValue }
    }
}


struct VisualEffectBackground: NSViewRepresentable {
    let overlayColor: Color
    private let material: NSVisualEffectView.Material
    private let blendingMode: NSVisualEffectView.BlendingMode
    private let isEmphasized: Bool
    
    init(
        overlayColor: Color = Color.white.opacity(0.1),
        material: NSVisualEffectView.Material = .fullScreenUI,
        blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
        emphasized: Bool = true) {
        self.overlayColor = overlayColor
        self.material = material
        self.blendingMode = blendingMode
        self.isEmphasized = emphasized
    }
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        
        let overlayView = NSView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.wantsLayer = true
        overlayView.layer?.backgroundColor = overlayColor.cgColor
        view.addSubview(overlayView)
        
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        
        // Not certain how necessary this is
        view.autoresizingMask = [.width, .height]
        
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = context.environment.visualEffectMaterial ?? material
        nsView.blendingMode = context.environment.visualEffectBlending ?? blendingMode
        nsView.isEmphasized = context.environment.visualEffectEmphasized ?? isEmphasized
    }
}

extension View {
    func visualEffect(
        material: NSVisualEffectView.Material,
        blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
        emphasized: Bool = false
    ) -> some View {
        background(
            VisualEffectBackground(
                material: material,
                blendingMode: blendingMode,
                emphasized: emphasized
            )
        )
    }
}

extension VisualEffectBackground {
    
    static var button : VisualEffectBackground {
        .init()
    }
    
}

struct AppBlurView<Content>: View where Content: View {
    
    let size: CGSize
    let padding: EdgeInsets
    let cornerRadius: CGFloat
    var tintColor: Color
    let content: () -> Content

    init(size: CGSize,
         padding: EdgeInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16),
         cornerRadius: CGFloat = 6.0,
         tintColor: Color = .tertiaryBackground.opacity(0.5),
         @ViewBuilder content: @escaping () -> Content) {
        self.size = size
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.tintColor = tintColor
        self.content = content
    }

    var body: some View {
        content()
            .frame(minWidth: size.width)
            .frame(height: size.height)
            .background(
                VisualEffectBackground(overlayColor: tintColor)
                    .cornerRadius(cornerRadius)
                    .padding(.horizontal, -(padding.leading)))
            .padding(.horizontal, padding.leading)
    }
}
#endif


