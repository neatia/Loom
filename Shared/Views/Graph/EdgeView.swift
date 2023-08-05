

import SwiftUI

typealias AnimatablePoint = AnimatablePair<CGFloat, CGFloat>
typealias AnimatableCorners = AnimatablePair<AnimatablePoint, AnimatablePoint>

struct EdgeView: Shape {
    var startx: CGFloat = 0
    var starty: CGFloat = 0
    var endx: CGFloat = 0
    var endy: CGFloat = 0
    
        // 1
    init(edge: EdgeProxy) {
            // 2
        startx = edge.start.x
        starty = edge.start.y
        endx = edge.end.x
        endy = edge.end.y
    }
    
        // 3
    func path(in rect: CGRect) -> Path {
        var linkPath = Path()
        linkPath.move(to: CGPoint(x: startx, y: starty)
                        .alignCenterInParent(rect.size))
        linkPath.addLine(to: CGPoint(x: endx, y:endy)
                            .alignCenterInParent(rect.size))
        return linkPath
    }
    
    var animatableData: AnimatableCorners {
        get { AnimatablePair(
            AnimatablePair(startx, starty),
            AnimatablePair(endx, endy))
        }
        set {
            startx = newValue.first.first
            starty = newValue.first.second
            endx = newValue.second.first
            endy = newValue.second.second
        }
    }
}

struct EdgeView_Previews: PreviewProvider {
    static var previews: some View {
        let edge1 = EdgeProxy(
            id: UUID(),
            start: CGPoint(x: -100, y: -100),
            end: CGPoint(x: 100, y: 100))
        let edge2 = EdgeProxy(
            id: UUID(),
            start: CGPoint(x: 100, y: -100),
            end: CGPoint(x: -100, y: 100))
        return ZStack {
            EdgeView(edge: edge1).stroke(lineWidth: 4)
            EdgeView(edge: edge2).stroke(Color.green, lineWidth: 2)
        }
    }
}
import CoreGraphics

extension CGPoint {
    func translatedBy(x: CGFloat, y: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + x, y: self.y + y)
    }
}

extension CGPoint {
    func alignCenterInParent(_ parent: CGSize) -> CGPoint {
        let x = parent.width/2 + self.x
        let y = parent.height/2 + self.y
        return CGPoint(x: x, y: y)
    }
    
    func scaledFrom(_ factor: CGFloat) -> CGPoint {
        return CGPoint(
            x: self.x * factor,
            y: self.y * factor)
    }
}

extension CGSize {
    func scaledDownTo(_ factor: CGFloat) -> CGSize {
        return CGSize(width: width/factor, height: height/factor)
    }
    
    var length: CGFloat {
        return sqrt(pow(width, 2) + pow(height, 2))
    }
    
    var inverted: CGSize {
        return CGSize(width: -width, height: -height)
    }
}
