import SwiftUI

public extension Float {
    
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
        Darwin.acos(self).radians
    }
    
    var asin: Angle {
        Darwin.asin(self).radians
    }
    
    var atan: Angle {
        Darwin.atan(self).radians
    }
}

