import CoreGraphics

public protocol RepresentableAsCGFloat {
    var asCGFloat: CGFloat {get}
}

extension Int: RepresentableAsCGFloat {
    public var asCGFloat: CGFloat {
        CGFloat(self)
    }
}

extension Float: RepresentableAsCGFloat {
    public var asCGFloat: CGFloat {
        CGFloat(self)
    }
}

extension Double: RepresentableAsCGFloat {
    public var asCGFloat: CGFloat {
        CGFloat(self)
    }
}

extension CGFloat: RepresentableAsCGFloat {
    public var asCGFloat: CGFloat {
        self
    }
}


