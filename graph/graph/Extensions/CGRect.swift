//
//  CGRect.swift
//  graph
//
//  Created by Noah Wilder on 2020-04-23.
//  Copyright © 2020 Noah Wilder. All rights reserved.
//

import Foundation

extension CGRect {
    
    /// Pads this rectangle using the specified edge insets.
    ///
    /// - Parameter insets: The edges to inset.
    /// - Returns: A rectangle that is padded using the specified edge insets.
    @inlinable public func padding(_ insets: EdgeInsets) -> CGRect {
        var paddedRect = self
        paddedRect.origin.x -= insets.leading
        paddedRect.origin.y -= insets.top
        paddedRect.size.width += insets.trailing + insets.leading
        paddedRect.size.height += insets.bottom + insets.top
        return paddedRect
    }
    
    /// Pads this rectangle on the specified edges.
    ///
    /// The following example only pads the horizontal edge insets by `10`:
    ///
    ///     let rectangle = CGRect(x: 0, y: 0, width: 100, height: 100)
    ///     let paddedRect = rectangle.padding([.horizontal], 10)
    ///
    /// - Parameters:
    ///     - edges: The set of edges along which to inset this rectangle.
    ///     - length: The amount to inset this rectangle on each edge.
    /// - Returns: A rectangle that is padded on `edges` to `length`.
    @inlinable public func padding(_ edges: Edge.Set = .all, _ length: CGFloat) -> CGRect {
        var insets = EdgeInsets()
        
        if edges.contains(.top) {
            insets.top = length
        }
        if edges.contains(.leading) {
            insets.leading = length
        }
        if edges.contains(.bottom) {
            insets.bottom = length
        }
        if edges.contains(.trailing) {
            insets.trailing = length
        }
        
        return padding(insets)
    }
    
    /// Pads this rectangle along all edge insets by the specified amount.
    ///
    /// - Parameter length: The amount to inset this rectangle on each edge.
    /// - Returns: A rectangle that is padded by the specified amount.
    @inlinable public func padding(_ length: CGFloat) -> CGRect {
        return padding(.all, length)
    }
}
