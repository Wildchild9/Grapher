//
//  Evaluation.swift
//  Expression Evaluator
//
//  Created by Noah Wilder on 2019-03-11.
//  Copyright © 2019 Noah Wilder. All rights reserved.
//

import Foundation




//MARK: -  Expression evaluation
public extension Expression {
    
    func evaluate(withX x: Double? = nil) -> Double {
        return _evaluate(withX: x)
        //return simplified()._evaluate(withX: x)
    }
    
    private func _evaluate(withX x: Double? = nil) -> Double {
        
        switch self {
        case let .add(a, b): return a._evaluate(withX: x) + b._evaluate(withX: x)
        case let .subtract(a, b): return a._evaluate(withX: x) - b._evaluate(withX: x)
        case let .multiply(a, b): return a._evaluate(withX: x) * b._evaluate(withX: x)
        case let .divide(a, b): return a._evaluate(withX: x) / b._evaluate(withX: x)
        case let .power(a, b): return pow(a._evaluate(withX: x), b._evaluate(withX: x))
        case let .log(a, b):
            switch a {
            case 10: return log10(b._evaluate(withX: x))
            case 2: return log2(b._evaluate(withX: x))
            default: return Foundation.log(b._evaluate(withX: x)) / Foundation.log(a._evaluate(withX: x))
            }
        case let .root(a, b):
            let r = a._evaluate(withX: x)
            if r == 2 {
                return sqrt(b._evaluate(withX: x))
            } else if r == 3 {
                return cbrt(b._evaluate(withX: x))
            }
            return pow(b._evaluate(withX: x), 1.0 / a._evaluate(withX: x))
        case let .n(a): return Double(a)
        case .x:
            guard let xValue = x else { fatalError("Requires x value to be solved") }
            return xValue
        }
    }
    
}

