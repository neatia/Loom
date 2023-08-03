/**
 This file is part of the Reductio package.
 (c) Sergio Fernández <fdz.sergio@gmail.com>

 For the full copyright and license information, please view the LICENSE
 file that was distributed with this source code.
 */

import Foundation

internal struct SentenceSearch {

    static func binary<T: Comparable>(_ array: [T], target: T) -> Bool {
        var left = 0
        var right = array.count - 1

        while left <= right {
            let mid = (left + right) / 2
            let value = array[mid]

            if value == target {
                return true
            }

            if value < target {
                left = mid + 1
            }

            if value > target {
                right = mid - 1
            }
        }
        return false
    }
}
