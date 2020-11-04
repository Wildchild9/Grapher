//
//  CGSize.swift
//  graph
//
//  Created by Noah Wilder on 2020-04-23.
//  Copyright © 2020 Noah Wilder. All rights reserved.
//

import Foundation

public extension CGSize {
    /// A size whose width and height are equal.
    static func square(sideLength: Int) -> CGSize {
        return CGSize(width: sideLength, height: sideLength)
    }
    
    /// A size whose width and height are equal.
    static func square(sideLength: Double) -> CGSize {
        return CGSize(width: sideLength, height: sideLength)
    }
    
    /// A size whose width and height are equal.
    static func square(sideLength: CGFloat) -> CGSize {
        return CGSize(width: sideLength, height: sideLength)
    }
}
