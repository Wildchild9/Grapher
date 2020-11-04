//
//  FloatingPoint.swift
//  graph
//
//  Created by Noah Wilder on 2020-04-23.
//  Copyright © 2020 Noah Wilder. All rights reserved.
//

import Foundation

extension FloatingPoint {
    /// Adjusts a value from its relative position in a range to the value at the same relative position
    /// in a target range.
    ///
    /// In the following example, `5` is adjusted from a base range of `0...10` to the value at the same
    /// relative position in the range `0...20`:
    ///
    ///     let a = 5.0
    ///     let b = a.adjusted(fromValueIn: 0...10, toValueIn: 0...20)
    ///     print(b)
    ///     // Prints "10.0"
    ///
    /// - Parameters:
    ///   - originRange: The range from which to derive the initial value's relative position.
    ///   - targetRange: The range from which to produce a value in the same relative position as that of
    ///   the initial value in `originRange`.
    ///
    /// - Returns: A value that is in the same relative position in a target range as the initial value in
    /// an origin range.
    func adjusted(fromValueIn originRange: ClosedRange<Self>, toValueIn targetRange: ClosedRange<Self>) -> Self {
        let distance1 = originRange.upperBound - originRange.lowerBound
        guard distance1 != 0 else {
            return targetRange.lowerBound
        }
        
        let distance2 = targetRange.upperBound - targetRange.lowerBound
        let newValue = (self - originRange.lowerBound) * distance2 / distance1 + targetRange.lowerBound
    
        return newValue
    }
}

//func adjust<T>(value: T, in originRange: ClosedRange<T>, toValueIn targetRange: ClosedRange<T>) -> T where T: FloatingPoint {
//    let distance1 = originRange.upperBound - originRange.lowerBound
//    guard distance1 != 0 else {
//        return targetRange.lowerBound
//    }
//
//    let distance2 = targetRange.upperBound - targetRange.lowerBound
//    let newValue = (value - originRange.lowerBound) * distance2 / distance1 + targetRange.lowerBound
//
//    return newValue
//}
