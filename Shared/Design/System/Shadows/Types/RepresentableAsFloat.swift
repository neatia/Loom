import CoreGraphics

public protocol RepresentableAsFloat {
    var asFloat: Float {get}
}

extension Int: RepresentableAsFloat {
    public var asFloat: Float {
        Float(self)
    }
}

extension Double: RepresentableAsFloat {
    public var asFloat: Float {
        Float(self)
    }
}

extension Float: RepresentableAsFloat {
    public var asFloat: Float {
        self
    }
}

extension CGFloat: RepresentableAsFloat {
    public var asFloat: Float {
        Float(self)
    }
}
