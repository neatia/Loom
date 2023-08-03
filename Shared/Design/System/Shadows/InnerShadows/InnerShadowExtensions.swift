
import Foundation
import SwiftUI

public extension Text {
    
//    internal func addgraniteInnerShadow<V: View>(_ content: V, _ config: granite_InnerShadowConfig) -> some View {
//        modifier(InnerShadowOnTextViewModifier(text: self, shadowContent: content, config: config))
//    }
    
    @inlinable
    func granite_innerShadow<T: UINumericType, TI: UINumericType>(radius: T, offset: CGPoint = .zero, intensity: TI) -> some View {
        granite_innerShadow(Color.clear, .config(radius: radius, offset: offset, intensity: intensity))
    }
    
    @inlinable
    func granite_innerShadow<V: View, T: UINumericType, TI: UINumericType>(_ content: V, radius: T, offset: CGPoint = .zero, intensity: TI) -> some View {
        granite_innerShadow(content, .config(radius: radius, offset: offset, intensity: intensity))
    }

    @inlinable
    func granite_innerShadow<T: UINumericType>(radius: T, offset: CGPoint = .zero, color: Color = granite_defaultInnerShadowColor) -> some View {
        granite_innerShadow(Color.clear, .config(radius: radius, offset: offset, color: color))
    }

    @inlinable
    func granite_innerShadow<V: View, T: UINumericType>(_ content: V, radius: T, offset: CGPoint = .zero, color: Color = granite_defaultInnerShadowColor) -> some View {
        granite_innerShadow(content, .config(radius: radius, offset: offset, color: color))
    }

    @inlinable
    func granite_innerShadow(_ config: granite_InnerShadowConfig) -> some View {
        granite_innerShadow(Color.clear, config)
    }

//    @inlinable
    func granite_innerShadow<V: View>(_ content: V, _ config: granite_InnerShadowConfig) -> some View {
//        addgraniteInnerShadow(content, config)
        modifier(InnerShadowOnTextViewModifier(text: self, shadowContent: content, config: config))
    }
}

//
//  granite_InnerShadowExtensions.swift
//
//
//  Created by Adam Fordyce on 06/03/2020.
//

private struct InnerShadowOnViewViewModifier<S: Shape, V: View>: ViewModifier {

    let shapeContent: ShapeAndContent<S, V>
    let config: granite_InnerShadowConfig

    func body(content: Content) -> some View {
        let decoration = Color.clear.background(self.shapeContent.shape.granite_innerShadow(.fill(self.shapeContent.content), self.config))
            .clipShape(self.shapeContent.shape)
        let color = self.shapeContent.content as? Color
        return RenderIf(color != nil && color == .clear) {
            content.overlay(decoration)
        }.elseRender {
            content.background(decoration)
        }
    }
}

public extension View {

    @inlinable
    func granite_innerShadow<T: UINumericType>(_ config: granite_InnerShadowConfig) -> some View {
        granite_innerShadow(ShapeAndContent(Rectangle(), Color.clear), config)
    }

    @inlinable
    func granite_innerShadow<T: UINumericType>(radius: T, offset: CGPoint = .zero, color: Color = granite_defaultInnerShadowColor) -> some View {
        granite_innerShadow(ShapeAndContent(Rectangle(), Color.clear), radius: radius, offset: offset, color: color)
    }

    @inlinable
    func granite_innerShadow<T: UINumericType, TD: UINumericType>(radius: T, offset: CGPoint = .zero, intensity: TD) -> some View {
        granite_innerShadow(ShapeAndContent(Rectangle(), Color.clear), .config(radius: radius, offset: offset, intensity: intensity))
    }

    func granite_innerShadow<S: Shape, V: View>(_ shapeContent: ShapeAndContent<S, V>, _ config: granite_InnerShadowConfig) -> some View {
        modifier(InnerShadowOnViewViewModifier(shapeContent: shapeContent, config: config))
    }

    @inlinable
    func granite_innerShadow<S: Shape, V: View, TR: UINumericType>(_ shapeContent: ShapeAndContent<S, V>, radius: TR, offset: CGPoint = .zero, color: Color = granite_defaultInnerShadowColor) -> some View {
        granite_innerShadow(shapeContent, .config(radius: radius, offset: offset, color: color))
    }

    @inlinable
    func granite_innerShadow<S: Shape, V: View, TR: UINumericType, TD: UINumericType>(_ shapeContent: ShapeAndContent<S, V>, radius: TR, offset: CGPoint = .zero, intensity: TD) -> some View {
        granite_innerShadow(shapeContent, .config(radius: radius, offset: offset, intensity: intensity))
    }

}
// MARK: -- INNER SHADOW OFFSET AND ANGLE

public extension View {

    @inlinable
    func granite_innerShadow(_ config: granite_InnerShadowConfig) -> some View {
        granite_innerShadow(Color.clear, config)
    }

    @inlinable
    func granite_innerShadow<TR: UINumericType, TO: UINumericType, TI: UINumericType>(radius: TR, offset: TO, angle: Angle, intensity: TI) -> some View {
        granite_innerShadow(Color.clear, radius: radius, offset: offset, angle: angle, intensity: intensity)
    }

    @inlinable
    func granite_innerShadow<TR: UINumericType, TO: UINumericType>(radius: TR, offset: TO, angle: Angle, color: Color = granite_defaultInnerShadowColor) -> some View {
        granite_innerShadow(Color.clear, radius: radius, offset: offset, angle: angle, color: color)
    }

    @inlinable
    func granite_innerShadow<V: View>(_ content: V, _ config: granite_InnerShadowConfig) -> some View {
        granite_innerShadow(.rectangle(content), config)
    }

    @inlinable
    func granite_innerShadow<V: View, TR: UINumericType, TO: UINumericType, TI: UINumericType>(_ content: V, radius: TR, offset: TO, angle: Angle, intensity: TI) -> some View {
        granite_innerShadow(.rectangle(content), radius: radius, offset: offset, angle: angle, intensity: intensity)
    }

    @inlinable
    func granite_innerShadow<V: View, TR: UINumericType, TO: UINumericType>(_ content: V, radius: TR, offset: TO, angle: Angle, color: Color = granite_defaultInnerShadowColor) -> some View {
        granite_innerShadow(.rectangle(content), radius: radius, offset: offset, angle: angle, color: color)
    }

    @inlinable
    func granite_innerShadow<S: Shape, V: View, TR: UINumericType, TO: UINumericType, TI: UINumericType>(_ shapeContent: ShapeAndContent<S, V>, radius: TR, offset: TO, angle: Angle, intensity: TI) -> some View {
        granite_innerShadow(shapeContent, .config(radius: radius, offset: offset, angle: angle, intensity: intensity))
    }

    @inlinable
    func granite_innerShadow<S: Shape, V: View, TR: UINumericType, TO: UINumericType>(_ shapeContent: ShapeAndContent<S, V>, radius: TR, offset: TO, angle: Angle, color: Color = granite_defaultInnerShadowColor) -> some View {
        granite_innerShadow(shapeContent, .config(radius: radius, offset: offset, angle: angle, color: color))
    }
}

private struct InnerShadowOnImageViewModifier<V: View>: ViewModifier {

    let image: Image
    let shadowContent: V
    let config: granite_InnerShadowConfig

    func body(content: Content) -> some View {
        RenderIf(config.hasAngle) {
            content.modifier(graniteInnerShadowImageOffsetWithAngleViewModifier(image: self.image, content: self.shadowContent, radius: self.config.radius, offset: self.config.offsetLength, angle: self.config.angle, color: self.config.color))
        }.elseRender {
            content.modifier(graniteInnerShadowImageOffsetViewModifier(image: self.image, content: self.shadowContent, radius: self.config.radius, offset: self.config.offset, color: self.config.color))
        }
    }
}

public extension Image {


//    func granite_innerShadow<V: View>(_ content: V, _ config: granite_InnerShadowConfig) -> some View {
//        modifier(InnerShadowOnImageViewModifier(image: self, shadowContent: content, config: config))
//    }

    @inlinable
    func granite_innerShadow<V: View, T: UINumericType, TI: UINumericType>(_ content: V, radius: T, offset: CGPoint = .zero, intensity: TI) -> some View {
        granite_innerShadow(content, .config(radius: radius, offset: offset, intensity: intensity))
    }

    @inlinable
    func granite_innerShadow<V: View, T: UINumericType>(_ content: V, radius: T, offset: CGPoint = .zero, color: Color = granite_defaultInnerShadowColor) -> some View {
        granite_innerShadow(content, .config(radius: radius, offset: offset, color: color))
    }

    @inlinable
    func granite_innerShadow(_ config: granite_InnerShadowConfig) -> some View {
        granite_innerShadow(Color.clear, config)
    }

    @inlinable
    func granite_innerShadow<T: UINumericType, TI: UINumericType>(radius: T, offset: CGPoint = .zero, intensity: TI) -> some View {
        granite_innerShadow(Color.clear, .config(radius: radius, offset: offset, intensity: intensity))
    }

    @inlinable
    func granite_innerShadow<T: UINumericType>(radius: T, offset: CGPoint = .zero, color: Color = granite_defaultInnerShadowColor) -> some View {
        granite_innerShadow(Color.clear, .config(radius: radius, offset: offset, color: color))
    }

    @inlinable
    func granite_innerShadow<V: View, TR: UINumericType, TO: UINumericType, TI: UINumericType>(_ content: V, radius: TR, offset: TO, angle: Angle, intensity: TI) -> some View {
        granite_innerShadow(content, .config(radius: radius, offset: offset, angle: angle, intensity: intensity))
    }

    @inlinable
    func granite_innerShadow<V: View, TR: UINumericType, TO: UINumericType>(_ content: V, radius: TR, offset: TO, angle: Angle, color: Color = granite_defaultInnerShadowColor) -> some View {
        granite_innerShadow(content, .config(radius: radius, offset: offset, angle: angle, color: color))
    }

    @inlinable
    func granite_innerShadow<TR: UINumericType, TO: UINumericType, TI: UINumericType>(radius: TR, offset: TO, angle: Angle, intensity: TI) -> some View {
        granite_innerShadow(.config(radius: radius, offset: offset, angle: angle, intensity: intensity))
    }

    @inlinable
    func granite_innerShadow<TR: UINumericType, TO: UINumericType>(radius: TR, offset: TO, angle: Angle, color: Color = granite_defaultInnerShadowColor) -> some View {
        granite_innerShadow(.config(radius: radius, offset: offset, angle: angle, color: color))
    }
}

// MARK: -- GENERIC ON SHAPE

private struct InnerShadowOnShapeViewModifier<S: Shape, V: View>: ViewModifier {

    let shape: S
    let fillAndContent: FillAndContent<V>
    let config: granite_InnerShadowConfig

    func body(content: Content) -> some View {
        RenderIf(config.hasAngle) {
            self.fillAndContent.content.clipShape(self.shape, style: self.fillAndContent.fillStyle)
                .modifier(graniteInnerShadowShapeOffsetWithAngleViewModifier(shape: self.shape, fillStyle: self.fillAndContent.fillStyle, radius: self.config.radius, offset: self.config.offsetLength, angle: self.config.angle, color: self.config.color))
       }.elseRender {
        self.fillAndContent.content.clipShape(self.shape, style: self.fillAndContent.fillStyle)
            .modifier(graniteInnerShadowShapeOffsetViewModifier(shape: self.shape, fillStyle: self.fillAndContent.fillStyle, radius: self.config.radius, offset: self.config.offset, color: self.config.color))
       }
    }
}

// MARK: -- GENERIC ON SHAPE STROKE

public extension Shape {

    func granite_innerShadow<V: View>(_ strokeAndContent: StrokeAndContent<V>, _ config: granite_InnerShadowConfig) -> some View {
        let strokedShape = stroke(style: strokeAndContent.style)
        return strokedShape.modifier(InnerShadowOnShapeViewModifier(shape: strokedShape, fillAndContent: strokeAndContent.fillAndContent, config: config))
    }

    @inlinable
    func granite_innerShadow<V: View, TR: UINumericType, TI: UINumericType>(_ strokeAndContent: StrokeAndContent<V>, radius: TR, offset: CGPoint = .zero, intensity: TI) -> some View {
        granite_innerShadow(strokeAndContent, .config(radius: radius, offset: offset, intensity: intensity))
    }

    @inlinable
    func granite_innerShadow<V: View, TR: UINumericType>(_ strokeAndContent: StrokeAndContent<V>, radius: TR, offset: CGPoint = .zero, color: Color = granite_defaultInnerShadowColor) -> some View {
        granite_innerShadow(strokeAndContent, .config(radius: radius, offset: offset, color: color))
    }

    @inlinable
    func granite_innerShadow<V: View, TR: UINumericType, TO: UINumericType, TI: UINumericType>(_ strokeAndContent: StrokeAndContent<V>, radius: TR, offset: TO, angle: Angle, intensity: TI) -> some View {
        granite_innerShadow(strokeAndContent, .config(radius: radius, offset: offset, angle: angle, intensity: intensity))
    }

    @inlinable
    func granite_innerShadow<V: View, TR: UINumericType, TO: UINumericType>(_ strokeAndContent: StrokeAndContent<V>, radius: TR, offset: TO, angle: Angle, color: Color = granite_defaultInnerShadowColor) -> some View {
        granite_innerShadow(strokeAndContent, .config(radius: radius, offset: offset, angle: angle, color: color))
    }
}

public extension Shape {


    @inlinable
    func granite_innerShadow<V: View, TR: UINumericType, TI: UINumericType>(_ fillAndContent: FillAndContent<V>, radius: TR, offset: CGPoint = .zero, intensity: TI) -> some View {
        granite_innerShadow(fillAndContent, .config(radius: radius, offset: offset, intensity: intensity))
    }

    @inlinable
    func granite_innerShadow<V: View, TR: UINumericType>(_ fillAndContent: FillAndContent<V>, radius: TR, offset: CGPoint = .zero, color: Color = granite_defaultInnerShadowColor) -> some View {
        granite_innerShadow(fillAndContent, .config(radius: radius, offset: offset, color: color))
    }

    @inlinable
    func granite_innerShadow<V: View, TR: UINumericType, TO: UINumericType, TI: UINumericType>(_ fillAndContent: FillAndContent<V>, radius: TR, offset: TO, angle: Angle, intensity: TI) -> some View {
        granite_innerShadow(fillAndContent, .config(radius: radius, offset: offset, angle: angle, intensity: intensity))
    }

    @inlinable
    func granite_innerShadow<V: View, TR: UINumericType, TO: UINumericType>(_ fillAndContent: FillAndContent<V>, radius: TR, offset: TO, angle: Angle, color: Color = granite_defaultInnerShadowColor) -> some View {
        granite_innerShadow(fillAndContent, .config(radius: radius, offset: offset, angle: angle, color: color))
    }
    
    func granite_innerShadow<V: View>(_ fillAndContent: FillAndContent<V>, _ config: granite_InnerShadowConfig) -> some View {
        modifier(InnerShadowOnShapeViewModifier(shape: self, fillAndContent: fillAndContent, config: config))
    }
}

// MARK: -- TEXT INNER SHADOW WITH OFFSET

private struct InnerShadowOnTextViewModifier<V: View>: ViewModifier {

    let text: Text
    let shadowContent: V
    let config: granite_InnerShadowConfig

    func body(content: Content) -> some View {
        RenderIf(config.hasAngle) {
            content.modifier(graniteInnerShadowTextOffsetWithAngleViewModifier(text: self.text, content: self.shadowContent, radius: self.config.radius, offset: self.config.offsetLength, angle: self.config.angle, color: self.config.color))
        }.elseRender {
            content.modifier(graniteInnerShadowTextOffsetViewModifier(text: self.text, content: self.shadowContent, radius: self.config.radius, offset: self.config.offset, color: self.config.color))
        }
    }
}
