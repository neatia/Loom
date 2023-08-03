/**
 This file is part of the Reductio package.
 (c) Sergio Fernández <fdz.sergio@gmail.com>

 For the full copyright and license information, please view the LICENSE
 file that was distributed with this source code.
 */

import Foundation

internal extension Array {
    private func addCombo(previous: [Element], pivotal: [Element]) -> [([Element], [Element])] {
        var pivotal = pivotal
        return (0..<pivotal.count).map { _ -> ([Element], [Element]) in
            return (previous + [pivotal.remove(at: 0)], pivotal)
        }
    }

    func combinations(length: Int) -> [[Element]] {

        return [Int](1...length)
            .reduce([([Element](), self)]) { (accum, _) in
                accum.flatMap(addCombo)
            }.map { $0.0 }
    }

    func slice(length: Int) -> [Element] {
        return self.prefix(length).map { $0 }
    }

    func slice(percent: Float) -> [Element] {
        if 0.0...1.0 ~= percent {
            let count = (Int(1-percent)*self.count)
            return slice(length: count)
        }
        return []
    }
}
