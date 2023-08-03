import SwiftUI

public extension CGFloat {
    
    var degrees: Angle {
        .degrees(asDouble)
    }
    
    var radians: Angle {
        .radians(asDouble)
    }
    
    var degreesAsRadians: Angle {
        asDouble.degreesAsRadians
    }
    
    var radiansAsDegrees: Angle {
        asDouble.radiansAsDegrees
    }
    
    var acos: Angle {
        Darwin.acos(asDouble).radians
    }
    
    var asin: Angle {
        Darwin.asin(asDouble).radians
    }
    
    var atan: Angle {
        Darwin.atan(asDouble).radians
    }
}
