//
//  GlobeScene.Helpers.swift
//  Loom
//
//  Created by PEXAVC on 8/8/23.
//

import Foundation
import SceneKit

extension SCNVector3 {
    /**
     * Calculates the cross product between two SCNVector3.
     */
    func cross(vector: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(y * vector.z - z * vector.y, z * vector.x - x * vector.z, x * vector.y - y * vector.x)
    }

    #if os(iOS)
    func length() -> Float {
        return sqrtf(x*x + y*y + z*z)
    }
    #else
    func length() -> Float {
        return Float(sqrt(x*x + y*y + z*z))
    }
    #endif

    /**
     * Normalizes the vector described by the SCNVector3 to length 1.0 and returns
     * the result as a new SCNVector3.
     */
    func normalized() -> SCNVector3 {
        return self / length()
    }
}

extension SCNMatrix4 {
    public init(x: SCNVector3, y: SCNVector3, z: SCNVector3, w: SCNVector3) {
        self.init(
            m11: x.x,
            m12: x.y,
            m13: x.z,
            m14: 0.0,

            m21: y.x,
            m22: y.y,
            m23: y.z,
            m24: 0.0,

            m31: z.x,
            m32: z.y,
            m33: z.z,
            m34: 0.0,

            m41: w.x,
            m42: w.y,
            m43: w.z,
            m44: 1.0)
    }
}

/**
 * Divides the x, y and z fields of a SCNVector3 by the same scalar value and
 * returns the result as a new SCNVector3.
 */
func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}

#if os(iOS)
func / (vector: SCNVector3, scalar: Float) -> SCNVector3 {
    return SCNVector3Make(vector.x / scalar, vector.y / scalar, vector.z / scalar)
}
#else
func / (vector: SCNVector3, scalar: Float) -> SCNVector3 {
    return SCNVector3Make(vector.x / CGFloat(scalar), vector.y / CGFloat(scalar), vector.z / CGFloat(scalar))
}
#endif

func * (left: SCNMatrix4, right: SCNMatrix4) -> SCNMatrix4 {
    return SCNMatrix4Mult(left, right)
}

//MARK: Animation

public extension GenericBezierPath {

    var elements: [PathElement] {
        var pathElements = [PathElement]()
        withUnsafeMutablePointer(to: &pathElements) { elementsPointer in
            cgPath.apply(info: elementsPointer) { (userInfo, nextElementPointer) in
                let nextElement = PathElement(element: nextElementPointer.pointee)
                let elementsPointer = userInfo!.assumingMemoryBound(to: [PathElement].self)
                elementsPointer.pointee.append(nextElement)
            }
        }
        return pathElements
    }
}

public enum PathElement {

    case moveToPoint(CGPoint)
    case addLineToPoint(CGPoint)
    case addQuadCurveToPoint(CGPoint, CGPoint)
    case addCurveToPoint(CGPoint, CGPoint, CGPoint)
    case closeSubpath

    init(element: CGPathElement) {
        switch element.type {
        case .moveToPoint: self = .moveToPoint(element.points[0])
        case .addLineToPoint: self = .addLineToPoint(element.points[0])
        case .addQuadCurveToPoint: self = .addQuadCurveToPoint(element.points[0], element.points[1])
        case .addCurveToPoint: self = .addCurveToPoint(element.points[0], element.points[1], element.points[2])
        case .closeSubpath: self = .closeSubpath
        }
    }
}

public extension SCNAction {

    class func moveAlong(path: GenericBezierPath, animationDuration: CGFloat = 0.5) -> SCNAction {

        let points = path.elements
        var actions = [SCNAction]()

        for point in points {

            switch point {
            case .moveToPoint(let a):
                let moveAction = SCNAction.move(to: SCNVector3(a.x, a.y, 0), duration: animationDuration)
                actions.append(moveAction)
                break

            case .addCurveToPoint(let a, let b, let c):
                let moveAction1 = SCNAction.move(to: SCNVector3(a.x, a.y, 0), duration: animationDuration)
                let moveAction2 = SCNAction.move(to: SCNVector3(b.x, b.y, 0), duration: animationDuration)
                let moveAction3 = SCNAction.move(to: SCNVector3(c.x, c.y, 0), duration: animationDuration)
                actions.append(moveAction1)
                actions.append(moveAction2)
                actions.append(moveAction3)
                break

            case .addLineToPoint(let a):
                let moveAction = SCNAction.move(to: SCNVector3(a.x, a.y, 0), duration: animationDuration)
                actions.append(moveAction)
                break

            case .addQuadCurveToPoint(let a, let b):
                let moveAction1 = SCNAction.move(to: SCNVector3(a.x, a.y, 0), duration: animationDuration)
                let moveAction2 = SCNAction.move(to: SCNVector3(b.x, b.y, 0), duration: animationDuration)
                actions.append(moveAction1)
                actions.append(moveAction2)
                break

            default:
                let moveAction = SCNAction.move(to: SCNVector3(0, 0, 0), duration: animationDuration)
                actions.append(moveAction)
                break
            }
        }
        return SCNAction.sequence(actions)
    }
}

#if os(macOS)
extension NSBezierPath {

    public var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)

        for i in 0 ..< elementCount {
            let type = element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath:
                path.closeSubpath()
            @unknown default:
                continue
            }
        }

        return path
    }
}
#endif
