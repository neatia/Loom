import Foundation
import SwiftUI

public extension CGPoint {
    
    var asAnimatablePair: AnimatablePair<CGFloat, CGFloat> {
        AnimatablePair(x, y)
    }
}

public extension AnimatablePair where First == CGFloat, Second == CGFloat {
    
    var asCGPoint: CGPoint {
        CGPoint(first, second)
    }
}

// MARK: -- INTERIOR SHADOW SHAPE VIEW MODIFIERS

public struct graniteInnerShadowShapeOffsetViewModifier<S: Shape>: AnimatableModifier {
    let shape: S
    let fillStyle: FillStyle
    var offset: CGPoint
    var radius: CGFloat
    var color: Color
    
    
    public var animatableData: AnimatablePair<AnimatablePair<CGFloat, CGFloat>, CGFloat> {
        get {
            AnimatablePair(AnimatablePair(offset.x, offset.y), radius)
        }
        set {
            offset = newValue.first.asCGPoint
            radius = newValue.second
        }
    }
    
    init<T: UINumericType>(shape: S, fillStyle: FillStyle, radius: T, offset: CGPoint = .zero, color: Color) {
        self.shape = shape
        self.fillStyle = fillStyle
        self.radius = radius.asCGFloat
        self.offset = offset
        self.color = color
    }
    
    public func body(content: Content) -> some View {
        content.modifier(graniteInnerShadowForShapeViewModifier(shape: shape, fillStyle: fillStyle, offset: offset, radius: radius, color: color))
    }
}

public struct graniteInnerShadowShapeOffsetWithAngleViewModifier<S: Shape>: AnimatableModifier {
    let shape: S
    let fillStyle: FillStyle
    var offset: CGFloat
    var angle: Angle
    var radius: CGFloat
    var color: Color
    
    public var animatableData: AnimatablePair<AnimatablePair<CGFloat, Double>, CGFloat> {
        get {
            AnimatablePair(AnimatablePair(offset, angle.degrees), radius)
        }
        set {
            offset = newValue.first.first
            angle = newValue.first.second.degrees
            radius = newValue.second
        }
    }
    
    init<T: UINumericType>(shape: S, fillStyle: FillStyle, radius: T, offset: CGFloat = 0, angle: Angle = .top, color: Color) {
        self.shape = shape
        self.fillStyle = fillStyle
        self.radius = radius.asCGFloat
        self.offset = offset
        self.angle = angle
        self.color = color
    }
    
    public func body(content: Content) -> some View {
        content.modifier(graniteInnerShadowForShapeViewModifier(shape: shape, fillStyle: fillStyle, offset: .point(offset, angle), radius: radius, color: color))
    }
}

private struct graniteInnerShadowForShapeViewModifier<S: Shape>: ViewModifier {

    let shape: S
    let fillStyle: FillStyle
    var offset: CGPoint
    var radius: CGFloat
    var color: Color

    func body(content: Content) -> some View {
        content.overlay(
            ZStack {
                shape.fill(self.color, style: fillStyle)
                shape.fill(Color.white, style: fillStyle)
                    .blur(radius: self.radius)
                    .offset(.init(self.offset.width, self.offset.height))
            }
            .clipShape(shape)
            .drawingGroup()
            .blendMode(.multiply)
        )
    }
}

// MARK: -- IMAGE VIEW MODIFIERS

public struct graniteInnerShadowImageOffsetViewModifier<V: View>: AnimatableModifier {
    let image: Image
    let content: V
    var offset: CGPoint
    var radius: CGFloat
    var color: Color
    
    public var animatableData: AnimatablePair<AnimatablePair<CGFloat, CGFloat>, CGFloat> {
        get {
            AnimatablePair(AnimatablePair(offset.x, offset.y), radius)
        }
        set {
            offset = newValue.first.asCGPoint
            radius = newValue.second
        }
    }
    
    init<T: UINumericType>(image: Image, content: V, radius: T, offset: CGPoint = .zero, color: Color) {
        self.image = image
        self.content = content
        self.radius = radius.asCGFloat
        self.offset = offset
        self.color = color
    }
    
    public func body(content: Content) -> some View {
        content.modifier(graniteInnerShadowForImageViewModifier(image: image, content: self.content, radius: radius, offset: offset, color: color))
    }
}

public struct graniteInnerShadowImageOffsetWithAngleViewModifier<V: View>: AnimatableModifier {
    
    let image: Image
    let content: V
    var offset: CGFloat
    var angle: Angle
    var radius: CGFloat
    var color: Color
    
    public var animatableData: AnimatablePair<AnimatablePair<CGFloat, Double>, CGFloat> {
        get {
            AnimatablePair(AnimatablePair(offset, angle.degrees), radius)
        }
        set {
            offset = newValue.first.first
            angle = newValue.first.second.degrees
            radius = newValue.second
        }
    }
    
    init<T: UINumericType>(image: Image, content: V, radius: T, offset: CGFloat = 0, angle: Angle = .top, color: Color) {
        self.image = image
        self.content = content
        self.radius = radius.asCGFloat
        self.offset = offset
        self.angle = angle
        self.color = color
    }
    
    public func body(content: Content) -> some View {
        content.modifier(graniteInnerShadowForImageViewModifier(image: image, content: self.content, radius: radius, offset: .point(offset, angle), color: color))
    }
}

private struct graniteInnerShadowForImageViewModifier<V: View>: ViewModifier {
    
    let image: Image
    let content: V
    var offset: CGPoint
    var radius: CGFloat
    var color: Color
    
    init(image: Image, content: V, radius: CGFloat, offset: CGPoint, color: Color) {
        self.image = image
        self.content = content
        self.radius = radius
        self.offset = offset
        self.color = color
    }
    
    func body(content: Content) -> some View {
        
        let templateImage = image.renderingMode(.template)
        let whiteTemplate = templateImage.foregroundColor(.white)
        return image
            .background(self.content.mask(whiteTemplate))
            .overlay(
                ZStack {
                    templateImage.foregroundColor(color)
                    templateImage.foregroundColor(.white).blur(radius: radius).offset(.init(self.offset.width, self.offset.height))
                }
                .mask(whiteTemplate)
                .blendMode(.multiply)
        )
        .foregroundColor(Color.clear)
    }
}

// MARK: -- TEXT INTERIOR SHADOW

public struct graniteInnerShadowTextOffsetViewModifier<V: View>: AnimatableModifier {
    let text: Text
    let content: V
    var offset: CGPoint
    var radius: CGFloat
    var color: Color
    
    public var animatableData: AnimatablePair<AnimatablePair<CGFloat, CGFloat>, CGFloat> {
        get {
            AnimatablePair(AnimatablePair(offset.x, offset.y), radius)
        }
        set {
            offset = newValue.first.asCGPoint
            radius = newValue.second
        }
    }
    
    init<T: UINumericType>(text: Text, content: V, radius: T, offset: CGPoint = .zero, color: Color) {
        self.text = text
        self.content = content
        self.radius = radius.asCGFloat
        self.offset = offset
        self.color = color
    }
    
    public func body(content: Content) -> some View {
        content.modifier(graniteInnerShadowForTextViewModifier(text: text, content: self.content, radius: radius, offset: offset, color: color))
    }
}

public struct graniteInnerShadowTextOffsetWithAngleViewModifier<V: View>: AnimatableModifier {
    
    let text: Text
    let content: V
    var offset: CGFloat
    var angle: Angle
    var radius: CGFloat
    var color: Color
    
    public var animatableData: AnimatablePair<AnimatablePair<CGFloat, Double>, CGFloat> {
        get {
            AnimatablePair(AnimatablePair(offset, angle.degrees), radius)
        }
        set {
            offset = newValue.first.first
            angle = newValue.first.second.degrees
            radius = newValue.second
        }
    }
    
    init<T: UINumericType>(text: Text, content: V, radius: T, offset: CGFloat = 0, angle: Angle = .top, color: Color) {
        self.text = text
        self.content = content
        self.radius = radius.asCGFloat
        self.offset = offset
        self.angle = angle
        self.color = color
    }
    
    public func body(content: Content) -> some View {
        content.modifier(graniteInnerShadowForTextViewModifier(text: text, content: self.content, radius: radius, offset: .point(offset, angle), color: color))
    }
}

private struct graniteInnerShadowForTextViewModifier<V: View>: ViewModifier {
    
    let text: Text
    let content: V
    var offset: CGPoint
    var radius: CGFloat
    var color: Color
    
    init(text: Text, content: V, radius: CGFloat, offset: CGPoint, color: Color) {
        self.text = text
        self.content = content
        self.radius = radius
        self.offset = offset
        self.color = color
    }
    
    func body(content: Content) -> some View {
        let whiteContent = text.foregroundColor(.white)
        
        return text
            .overlay(self.content.mask(whiteContent))
            .overlay(
                ZStack {
                    text.foregroundColor(color)
                    text.foregroundColor(.white).blur(radius: radius).offset(.init(self.offset.width, self.offset.height))
                }
                .mask(whiteContent)
                .blendMode(.multiply)
        )
            .foregroundColor(Color.clear)
        
    }
}
