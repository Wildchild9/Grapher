//
//  EdgeInsets.swift
//  graph
//
//  Created by Noah Wilder on 2020-04-23.
//  Copyright © 2020 Noah Wilder. All rights reserved.
//

import Foundation

public struct EdgeInsets: Equatable {
    
    public var top: CGFloat
    public var leading: CGFloat
    public var bottom: CGFloat
    public var trailing: CGFloat
    
    @inlinable public init(top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat) {
        self.top = top
        self.leading = leading
        self.bottom = bottom
        self.trailing = trailing
    }
    
    @inlinable public init() {
        self.top = 0
        self.leading = 0
        self.bottom = 0
        self.trailing = 0
    }
    
    public static func ==(lhs: EdgeInsets, rhs: EdgeInsets) -> Bool {
        return lhs.top == rhs.top &&
            lhs.leading == rhs.leading &&
            lhs.bottom == rhs.bottom &&
            lhs.trailing == rhs.trailing
    }
}

