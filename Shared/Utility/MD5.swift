//
//  MD5.swift
//  Loom
//
//  Created by PEXAVC on 8/27/23.
//

/*
 * In this file, CommonCrypto is used to create md5 hash.
 * CommonCrypto is created by Marcin Krzyżanowski.
 * https://github.com/krzyzanowskim/CryptoSwift
 * The original copyright is here.
 */

/*
 * Copyright (C) 2014 Marcin Krzyżanowski marcin.krzyzanowski@gmail.com
 * This software is provided 'as-is', without any express or implied warranty.
 *
 * In no event will the authors be held liable for any damages arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 *
 * - The origin of this software must not be misrepresented; you must not claim that you wrote the original software.
 *   If you use this software in a product, an acknowledgment in the product documentation is required.
 * - Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * - This notice may not be removed or altered from any source or binary distribution.
 */

import Foundation
import CommonCrypto

extension String {
    public func md5() -> String {
        let md5 = MD5().calculate(for: self.utf8.lazy.map({ $0 as UInt8 }))
        return md5.lazy.reduce("") {
            var s = String($1, radix: 16)
            if s.count == 1 {
                s = "0" + s
            }
            return $0 + s
        }
    }
}

private final class MD5 {
    private struct BytesSequence: Sequence {
        let chunkSize: Int
        let data: Array<UInt8>
        
        func makeIterator() -> AnyIterator<ArraySlice<UInt8>> {
            var offset = data.startIndex
            return AnyIterator {
                let end = Swift.min(self.chunkSize, self.data.count &- offset)
                let result = self.data[offset ..< offset &+ end]
                offset = offset.advanced(by: result.count)
                if !result.isEmpty {
                    return result
                }
                return nil
            }
        }
    }
    
    static let blockSize: Int = 64
    static let digestLength: Int = 16 // 128 / 8
    fileprivate static let hashInitialValue: [UInt32] = [0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476]
    
    fileprivate var accumulated: [UInt8] = []
    fileprivate var processedBytesTotalCount: Int = 0
    fileprivate var accumulatedHash: [UInt32] = MD5.hashInitialValue
    
    /** specifies the per-round shift amounts */
    private let s: [UInt32] = [7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
                               5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20,
                               4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
                               6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21]
    
    /** binary integer part of the sines of integers (Radians) */
    private let k: [UInt32] = [0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
                               0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
                               0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
                               0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
                               0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
                               0xd62f105d, 0x2441453, 0xd8a1e681, 0xe7d3fbc8,
                               0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
                               0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
                               0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
                               0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
                               0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x4881d05,
                               0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
                               0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
                               0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
                               0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
                               0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391]
    
    init() {}
    
    func calculate(for bytes: [UInt8]) -> [UInt8] {
        do {
            return try self.update(withBytes: bytes, isLast: true)
        } catch {
            fatalError()
        }
    }
    
    // mutating currentHash in place is way faster than returning new result
    private func process(block chunk: ArraySlice<UInt8>, currentHash: inout [UInt32]) {
        
        // break chunk into sixteen 32-bit words M[j], 0 ≤ j ≤ 15
        var M: [UInt32] = {
            var result: [UInt32] = []
            result.reserveCapacity(16)
            for idx in stride(from: chunk.startIndex, to: chunk.endIndex, by: MemoryLayout<UInt32>.size) {
                var val: UInt32 = 0
                val |= chunk.count > 3 ? UInt32(chunk[idx.advanced(by: 3)]) << 24 : 0
                val |= chunk.count > 2 ? UInt32(chunk[idx.advanced(by: 2)]) << 16 : 0
                val |= chunk.count > 1 ? UInt32(chunk[idx.advanced(by: 1)]) << 8 : 0
                val |= chunk.count > 0 ? UInt32(chunk[idx]) : 0
                result.append(val)
            }
            return result
        }()
        assert(M.count == 16, "Invalid array")
        
        // Initialize hash value for this chunk:
        var A: UInt32 = currentHash[0]
        var B: UInt32 = currentHash[1]
        var C: UInt32 = currentHash[2]
        var D: UInt32 = currentHash[3]
        
        var dTemp: UInt32 = 0
        
        func rotateLeft(_ value: UInt32, by: UInt32) -> UInt32 {
            return ((value << by) & 0xFFFFFFFF) | (value >> (32 - by))
        }
        // Main loop
        for j in 0 ..< k.count {
            var g = 0
            var F: UInt32 = 0
            
            switch (j) {
            case 0 ... 15:
                F = (B & C) | ((~B) & D)
                g = j
                break
            case 16 ... 31:
                F = (D & B) | (~D & C)
                g = (5 * j + 1) % 16
                break
            case 32 ... 47:
                F = B ^ C ^ D
                g = (3 * j + 5) % 16
                break
            case 48 ... 63:
                F = C ^ (B | (~D))
                g = (7 * j) % 16
                break
            default:
                break
            }
            dTemp = D
            D = C
            C = B
            B = B &+ rotateLeft(A &+ F &+ k[j] &+ M[g], by: s[j])
            A = dTemp
        }
        
        currentHash[0] = currentHash[0] &+ A
        currentHash[1] = currentHash[1] &+ B
        currentHash[2] = currentHash[2] &+ C
        currentHash[3] = currentHash[3] &+ D
    }
    
    func update<T: Collection>(withBytes bytes: T, isLast: Bool = false) throws -> [UInt8] where T.Iterator.Element == UInt8 {
        self.accumulated += bytes
        
        if isLast {
            let lengthInBits = (self.processedBytesTotalCount + self.accumulated.count) * 8
            let lengthBytes:[UInt8] = {
                let totalBytes: Int = 64 / 8 // A 64-bit representation of b
                let value = lengthInBits
                let valuePointer = UnsafeMutablePointer<Int>.allocate(capacity: 1)
                valuePointer.pointee = value
                
                let bytesPointer = UnsafeMutablePointer<UInt8>(OpaquePointer(valuePointer))
                var bytes = Array<UInt8>(repeating: 0, count: totalBytes)
                for j in 0 ..< min(MemoryLayout<T>.size, totalBytes) {
                    bytes[totalBytes - 1 - j] = (bytesPointer + j).pointee
                }

                #if swift(>=4.1)
                valuePointer.deinitialize(count: 1)
                valuePointer.deallocate()
                #else
                valuePointer.deinitialize()
                valuePointer.deallocate(capacity: 1)
                #endif
                
                return bytes
            }()
            
            /**
             ISO/IEC 9797-1 Padding method 2.
             Add a single bit with value 1 to the end of the data.
             If necessary add bits with value 0 to the end of the data until the padded data is a multiple of blockSize.
             - parameters:
             - blockSize: Padding size in bytes.
             - allowance: Excluded trailing number of bytes.
             */
            @inline(__always)
            func bitPadding(to data: inout [UInt8], blockSize: Int, allowance: Int = 0) {
                let msgLength = data.count
                // Step 1. Append Padding Bits
                // append one bit (UInt8 with one bit) to message
                data.append(0x80)
                
                // Step 2. append "0" bit until message length in bits ≡ 448 (mod 512)
                let max = blockSize - allowance // 448, 986
                if msgLength % blockSize < max { // 448
                    data += [UInt8](repeating: 0, count: max - 1 - (msgLength % blockSize))
                } else {
                    data += [UInt8](repeating: 0, count: blockSize + max - 1 - (msgLength % blockSize))
                }
            }
            
            // Step 1. Append padding
            bitPadding(to: &self.accumulated, blockSize: MD5.blockSize, allowance: 64 / 8)
            
            // Step 2. Append Length a 64-bit representation of lengthInBits
            self.accumulated += lengthBytes.reversed()
        }
        
        var processedBytes = 0
        for chunk in BytesSequence(chunkSize: MD5.blockSize, data: self.accumulated) {
            if (isLast || (self.accumulated.count - processedBytes) >= MD5.blockSize) {
                self.process(block: chunk, currentHash: &self.accumulatedHash)
                processedBytes += chunk.count
            }
        }
        self.accumulated.removeFirst(processedBytes)
        self.processedBytesTotalCount += processedBytes
        
        // output current hash
        var result: [UInt8] = []
        result.reserveCapacity(MD5.digestLength)
        
        for hElement in self.accumulatedHash {
            let hLE = hElement.littleEndian
            result += [UInt8(hLE & 0xff), UInt8((hLE >> 8) & 0xff), UInt8((hLE >> 16) & 0xff), UInt8((hLE >> 24) & 0xff)]
        }
        
        // reset hash value for instance
        if isLast {
            self.accumulatedHash = MD5.hashInitialValue
        }
        
        return result
    }
}
