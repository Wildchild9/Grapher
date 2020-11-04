//
//  Edge.swift
//  graph
//
//  Created by Noah Wilder on 2020-04-23.
//  Copyright © 2020 Noah Wilder. All rights reserved.
//

import Foundation

public enum Edge: Int8, CaseIterable {
    
    case top = 0
    case leading
    case bottom
    case trailing
    
    public struct Set: OptionSet {
        public typealias RawValue = Int8
        
        public let rawValue: Int8
        
        public static let top = Edge.Set(rawValue: 1 << 0)
        public static let leading = Edge.Set(rawValue: 1 << 1)
        public static let bottom = Edge.Set(rawValue: 1 << 2)
        public static let trailing = Edge.Set(rawValue: 1 << 3)
        
        public static let horizontal: Edge.Set = [.leading, .trailing]
        public static let vertical: Edge.Set = [.top, .bottom]
        
        public static let all: Edge.Set = [.top, .leading, .bottom, .trailing]
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        /// Creates an instance containing just `e`.
        public init(_ e: Edge) {
            switch e {
            case .top: self = Edge.Set.top
            case .leading: self = Edge.Set.leading
            case .bottom: self = Edge.Set.bottom
            case .trailing: self = Edge.Set.trailing
            }
        }
    }
}
