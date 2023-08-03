public extension Comparable {
    
    func clamped(from: Self, to: Self) -> Self {
        if (self > to) {
            return to
        } else if (self < from) {
            return from
        }
        return self
    }
}
