import CoreGraphics

public protocol RepresentableAsDouble {
    var asDouble: Double {get}
}

extension Int: RepresentableAsDouble {
    public var asDouble: Double {
        Double(self)
    }
}

extension Float: RepresentableAsDouble {
    public var asDouble: Double {
        Double(self)
    }
}

extension Double: RepresentableAsDouble {
    public var asDouble: Double {
        self
    }
}

extension CGFloat: RepresentableAsDouble {
    public var asDouble: Double {
        Double(self)
    }
}


