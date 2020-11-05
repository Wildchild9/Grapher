//
//  Expression.swift
//  graph
//
//  Created by Noah Wilder on 2020-11-04.
//  Copyright © 2020 Noah Wilder. All rights reserved.
//

import Foundation

enum TokenClassification: Parsable, CaseIterable {
    typealias Base = Self
    
    case left_parenthesis
    case right_parenthesis
    case number
    case binary_operator
    case prefix_operator
    case postfix_operator
    case identifier
    case whitespace
    case comma_separator
    
    private static let digit = "0" || "1" || "2" || "3" || "4" || "5" || "6" || "7" || "8" || "9"
    private static let digits = RecursiveTokenPattern { digit + $0.opt() }
    
    private static let letter = \Character.isLetter
    private static let identifier_head = letter || "_"
    private static let identifier_character = identifier_head || digit
    private static let identifier_characters = RecursiveTokenPattern { identifier_character + $0.opt() }
    
    var pattern: TokenPattern {
        switch self {
        case .left_parenthesis: return "("
        case .right_parenthesis: return ")"
        case .number: return Self.digits + ("." + Self.digits).opt()
        case .binary_operator: return "+" || "-" || "*" || "/" || "^"
        case .prefix_operator: return "+" || "-"
        case .postfix_operator: return "++" || "--"
        case .identifier: return Self.identifier_head + Self.identifier_characters.opt()
        case .whitespace: return \Character.isWhitespace
        case .comma_separator: return ","
        }
    }
    
    static var grammarPattern: AnyGrammarPattern<Self> {
        let whitespaces = RecursiveGrammarPattern { whitespace + $0.opt() }
        let expression = SharedGrammarPattern<Self>()
        let expression_list = RecursiveGrammarPattern { expression + (whitespaces.opt() + comma_separator + whitespaces.opt() + $0).opt() }
        
        //        let function1 = identifier + whitespaces.opt()
        //        let function2 = left_parenthesis + whitespaces.opt() + expression_list + whitespaces.opt() + right_parenthesis
        //        let function = function1 + function2
        
        let parenthesized_expression = left_parenthesis + whitespaces.opt() + expression + whitespace.opt() + right_parenthesis
        // let primary_expression = number || function || identifier || parenthesized_expression
        let function_call = left_parenthesis + whitespaces.opt() + expression_list + whitespaces.opt() + right_parenthesis
        let primary_expression = number || (identifier + function_call.opt()) || parenthesized_expression
        
        //        let postfix_expression = primary_expression //+ postfix_operator.opt()
        
        let prefix_expression = prefix_operator.opt() + primary_expression //postfix_expression
        
        let spaced_binary_operator = whitespaces + binary_operator + whitespaces
        let binary_expression = (postfix_operator.opt() + spaced_binary_operator + prefix_expression) || (binary_operator + primary_expression)
        //        let binary_expression = ((postfix_operator.opt() + whitespaces + binary_operator + whitespaces) || binary_operator) + prefix_expression
        //(binary_operator || (postfix_operator.opt() + whitespaces + binary_operator + whitespaces)) + prefix_expression
        let binary_expressions = RecursiveGrammarPattern { binary_expression + $0.opt() }
        
        expression.pattern = AnyGrammarPattern(AnyGrammarPattern(prefix_expression + binary_expressions.opt()) + postfix_operator.opt())
        
        return AnyGrammarPattern(AnyGrammarPattern(whitespaces.opt() + expression) + whitespaces.opt())
    }
}

struct Function: Hashable {
    var identifier: String
    var arity: UInt
    var apply: ([Double]) -> Double
    
    init(_ identifier: String, arity: UInt, function: @escaping ([Double]) -> Double) {
        self.identifier = identifier
        self.arity = arity
        self.apply = function
    }
    func evaluate(with arguments: [Double]) -> Double {
        guard arguments.count == arity else { fatalError("The length of the arguments must be equal to the arity of the function.") }
        return apply(arguments)
    }
    static func ==(lhs: Function, rhs: Function) -> Bool {
        return lhs.arity == rhs.arity && lhs.identifier == rhs.identifier
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(arity)
        hasher.combine(identifier)
    }
}
class Constant: Hashable {
    var identifier: String
    var value: Double
    
    init(_ identifier: String, value: Double) {
        self.identifier = identifier
        self.value = value
    }
    static func ==(lhs: Constant, rhs: Constant) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
struct PrefixOperator: Hashable {
    var identifier: String
    var apply: (Double) -> Double
    
    init(_ identifier: String, function: @escaping (Double) -> Double) {
        self.identifier = identifier
        self.apply = function
    }
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
struct PostfixOperator: Hashable {
    var identifier: String
    var apply: (Double) -> Double
    
    init(_ identifier: String, function: @escaping (Double) -> Double) {
        self.identifier = identifier
        self.apply = function
    }
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
struct InfixOperator: Hashable {
    var identifier: String
    var associativity: Associativity = .left
    var precedence: Double = 0
    var apply: (Double, Double) -> Double
    
    enum Associativity {
        case left, right
    }
    
    init(_ identifier: String, associativity: Associativity = .left, precedence: Double = 0, function: @escaping (Double, Double) -> Double) {
        self.identifier = identifier
        self.associativity = associativity
        self.precedence = precedence
        self.apply = function
    }
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

final class LookupTable {
    private(set) static var functions = Set<Function>()
    private(set) static var constants = Set<Constant>()
    private(set) static var infixOperators = Set<InfixOperator>()
    private(set) static var prefixOperators = Set<PrefixOperator>()
    private(set) static var postfixOperators = Set<PostfixOperator>()
    
    static func define(function: Function) throws {
        guard functions.insert(function).inserted else {
            throw LookupTable.Error.conflictsWithPreviousDefinition
        }
    }
    static func define(constant: Constant) throws {
        guard constants.insert(constant).inserted else {
            throw LookupTable.Error.conflictsWithPreviousDefinition
        }
    }
    static func define(infixOperator: InfixOperator) throws {
        guard infixOperators.insert(infixOperator).inserted else {
            throw LookupTable.Error.conflictsWithPreviousDefinition
        }
    }
    static func define(prefixOperator: PrefixOperator) throws {
        guard prefixOperators.insert(prefixOperator).inserted else {
            throw LookupTable.Error.conflictsWithPreviousDefinition
        }
    }
    static func define(postfixOperator: PostfixOperator) throws {
        guard postfixOperators.insert(postfixOperator).inserted else {
            throw LookupTable.Error.conflictsWithPreviousDefinition
        }
    }
    
    static func lookupPrefixOperator(identifier: String) throws -> PrefixOperator {
        guard let op = prefixOperators.first(where: { $0.identifier == identifier }) else {
            throw Error.undefinedPrefixOperator
        }
        return op
    }
    static func lookupPostfixOperator(identifier: String) throws -> PostfixOperator {
        guard let op = postfixOperators.first(where: { $0.identifier == identifier }) else {
            throw Error.undefinedPostfixOperator
        }
        return op
    }
    static func lookupInfixOperator(identifier: String) throws -> InfixOperator {
        guard let op = infixOperators.first(where: { $0.identifier == identifier }) else {
            throw Error.undefinedInfixOperator
        }
        return op
    }
    static func lookupConstant(identifier: String) throws -> Constant {
        guard let constant = constants.first(where: { $0.identifier == identifier }) else {
            throw Error.undefinedConstant
        }
        return constant
    }
    static func lookupFunction(identifier: String, arity: UInt) throws -> Function {
        guard let function = functions.first(where: { $0.identifier == identifier && $0.arity == arity }) else {
            throw Error.undefinedFunction
        }
        return function
    }
    static func lookupFunctions(identifier: String) throws -> [Function] {
        let matchingFunctions = functions.filter { $0.identifier == identifier }
        guard !matchingFunctions.isEmpty else {
            throw Error.undefinedFunction
        }
        return matchingFunctions.sorted { $0.arity < $1.arity }
    }
    
    static func updateConstant(withIdentifier identifier: String, to newValue: Double) throws {
        guard let constant = constants.first(where: { $0.identifier == identifier }) else {
            throw Error.undefinedConstant
        }
        constant.value = newValue
    }
    
    enum Error: Swift.Error {
        case conflictsWithPreviousDefinition
        case undefinedPrefixOperator
        case undefinedInfixOperator
        case undefinedPostfixOperator
        case undefinedConstant
        case undefinedFunction
        case value
    }
}

enum Expression {
    indirect case infixOperator(InfixOperator, lhs: Self, rhs: Self)
    indirect case postfixOperator(PostfixOperator, Self)
    indirect case prefixOperator(PrefixOperator, Self)
    indirect case function(Function, arguments: [Self])
    case constant(Constant)
    case number(Double)
    
    static let zero: Self = .number(.zero)
    
    func evaluated() -> Double {
        switch self {
        case let .infixOperator(op, lhs: lhs, rhs: rhs):
            return op.apply(lhs.evaluated(), rhs.evaluated())
        case let .prefixOperator(op, exp):
            return op.apply(exp.evaluated())
        case let .postfixOperator(op, exp):
            return op.apply(exp.evaluated())
        case let .function(function, arguments: args):
            return function.apply(args.map { $0.evaluated() })
        case let .constant(constant):
            return constant.value
        case let .number(n):
            return n
        }
    }
}

typealias Token = MatchedToken<TokenClassification>

enum SemaError: Error {
    case infixOperatorSpacing
    case invalidSpacing
    case invalidOperator
    case invalidSeparator
    case functionDoesNotExist(identifier: String, arity: Int? = nil)
    case missingTokens
    case functionDoesNotTerminate(identifier: String)
    case constantDoesNotExist(identifier: String)
    case invalidToken(Token, output: [Token], stack: [Token], idx: Array<Token>.Index)
    case unbalancedParentheses
}

// Puts the tokens into postfix notation
func postfixTokens(from tokens: [Token]) throws -> (tokens: [Token], constantsAndFunctions: [Either<Constant, Function>]) {
    var stack = [Token]()
    var output = [Token]()
    let tokens = tokens.filter { $0.classification != .whitespace }
    var idx = tokens.startIndex
    var constantsAndFunctions = [Either<Constant, Function>]()
    
    while idx < tokens.endIndex {
        let token = tokens[idx]
        let nextToken = idx + 1 < tokens.endIndex ? tokens[idx + 1] : nil
        
        mainTokenClassification:
        switch token.classification {
        
        case .whitespace:
            break
            
        case .comma_separator:
            throw SemaError.invalidSeparator
            
        case .number:
            output.append(token)
            if nextToken?.classification != .postfix_operator {
                while stack.last?.classification == .prefix_operator {
                    output.append(stack.removeLast())
                }
            }
            
            
        case .left_parenthesis:
            stack.append(token)
            
        case .prefix_operator:
            stack.append(token)
            
        case .binary_operator:
            guard let currentOpertor = try? LookupTable.lookupInfixOperator(identifier: String(token.match)) else {
                throw SemaError.invalidOperator
            }
            while let operatorToken = stack.last, operatorToken.classification == .binary_operator, let op = try? LookupTable.lookupInfixOperator(identifier: String(operatorToken.match)), op.precedence >= currentOpertor.precedence {
                stack.removeLast()
                output.append(operatorToken)
            }
            stack.append(token)
            
        case .postfix_operator:
            output.append(Token(classification: .postfix_operator, match: token.match))
            if nextToken?.classification != .postfix_operator {
                while stack.last?.classification == .prefix_operator {
                    output.append(stack.removeLast())
                }
            }
            
        // Matches functions
        case .identifier where nextToken?.classification == .left_parenthesis:
            let identifier = String(token.match)
            guard let functions = try? LookupTable.lookupFunctions(identifier: identifier) else {
                throw SemaError.functionDoesNotExist(identifier: identifier)
            }
            var depth = 1
            // Ensure there are tokens after the left parentheses
            guard idx + 2 < tokens.endIndex else {
                throw SemaError.missingTokens
            }
            var arguments = [[Token]]()
            var currentArgument = [Token]()
            
            for (i, currentToken) in tokens[(idx + 2)...].enumerated() {
                switch currentToken.classification {
                case .left_parenthesis:
                    depth += 1
                    currentArgument.append(currentToken)
                    
                case .right_parenthesis where depth == 1:
                    // Adds to the output the function in postfix notation
                    let argument = try postfixTokens(from: currentArgument)
                    constantsAndFunctions.append(contentsOf: argument.constantsAndFunctions)
                    arguments.append(argument.tokens)
                    output.append(contentsOf: arguments.flatMap { $0 })
                    output.append(token)
                    guard let function = functions.first(where: { $0.arity == arguments.count }) else {
                        throw SemaError.functionDoesNotExist(identifier: identifier, arity: arguments.count)
                    }
                    constantsAndFunctions.append(.right(function))
                    idx += 2 + i
                    if idx + 1 < tokens.endIndex, tokens[idx + 1].classification != .postfix_operator {
                        while stack.last?.classification == .prefix_operator {
                            output.append(stack.removeLast())
                        }
                    }
                    break mainTokenClassification
                    
                case .right_parenthesis:
                    depth -= 1
                    currentArgument.append(currentToken)
                    
                case .comma_separator where depth == 1:
                    let argument = try postfixTokens(from: currentArgument)
                    arguments.append(argument.tokens)
                    constantsAndFunctions.append(contentsOf: argument.constantsAndFunctions)
                    currentArgument.removeAll()
                    
                default:
                    currentArgument.append(currentToken)
                }
            }
            
            throw SemaError.functionDoesNotTerminate(identifier: identifier)
            
        case .identifier:
            let identifier = String(token.match)
            guard let constant = try? LookupTable.lookupConstant(identifier: identifier) else {
                throw SemaError.constantDoesNotExist(identifier: identifier)
            }
            output.append(token)
            constantsAndFunctions.append(.left(constant))
            if nextToken?.classification != .postfix_operator {
                while stack.last?.classification == .prefix_operator {
                    output.append(stack.removeLast())
                }
            }
            
        case .right_parenthesis:
            for stackToken in stack.reversed() {
                stack.removeLast()
                if stackToken.classification == .left_parenthesis {
                    if nextToken?.classification != .postfix_operator {
                        while stack.last?.classification == .prefix_operator {
                            output.append(stack.removeLast())
                        }
                    }
                    break mainTokenClassification
                }
                output.append(stackToken)
            }
            throw SemaError.unbalancedParentheses
            
        }
        
        // Increment token index
        idx += 1
        
    }
    while !stack.isEmpty {
        output.append(stack.removeLast())
    }
    return (tokens: output, constantsAndFunctions)
}


func createAST(from postfixData: (tokens: [Token], constantsAndFunctions: [Either<Constant, Function>])) throws -> Expression {
    let (tokens, constantsAndFunctions) = postfixData
    guard let lastToken = tokens.last else {
        fatalError()
    }
    guard tokens.count > 1 else {
        let match = String(lastToken.match)
        switch lastToken.classification {
        case .identifier:
            guard case let .left(constant) = constantsAndFunctions.first!, constant.identifier == match else {
                fatalError()
            }
            return .constant(constant)
        case .number:
            return .number(Double(match)!)
        default:
            fatalError("Invalid token for single token expression.")
        }
    }
    
    var identifierIterator = constantsAndFunctions.makeIterator()
    var arr = [Either<Expression, Token>]()
    arr = tokens.map { .right($0) }
    var i = 0
    while i != arr.endIndex {
        guard case let .right(element) = arr[i] else { fatalError() }
        let match = String(element.match)
        switch element.classification {
        case .left_parenthesis, .right_parenthesis, .whitespace, .comma_separator:
            fatalError("This token should not be present in this stage.")
        case .number:
            arr[i] = .left(.number(Double(match)!))
            i += 1
        case .binary_operator:
            guard i >= 2, case let .left(lhs) = arr[i - 1], case let .left(rhs) = arr[i - 2] else {
                fatalError("Invalid binary operator token position.")
            }
            let infixOperator = try LookupTable.lookupInfixOperator(identifier: match)
            arr[(i - 2)...i] = [.left(.infixOperator(infixOperator, lhs: rhs, rhs: lhs))]
            i -= 1
            
        case .prefix_operator:
            guard i >= 1, case let .left(expression) = arr[i - 1] else {
                fatalError("Invalid prefix operator token position.")
            }
            let prefixOperator = try LookupTable.lookupPrefixOperator(identifier: match)
            arr[(i - 1)...i] = [.left(.prefixOperator(prefixOperator, expression))]
            
        case .postfix_operator:
            guard i >= 1, case let .left(expression) = arr[i - 1] else {
                fatalError("Invalid postfix operator token position.")
            }
            let postfixOperator = try LookupTable.lookupPostfixOperator(identifier: match)
            arr[(i - 1)...i] = [.left(.postfixOperator(postfixOperator, expression))]
            
        case .identifier:
            guard let identifier = identifierIterator.next() else {
                fatalError()
            }
            // If this is true, the identifier is a constant
            switch identifier {
            case let .left(constant):
                guard constant.identifier == match else { fatalError() }
                arr[i] = .left(.constant(constant))
                i += 1
            case let .right(function):
                guard function.identifier == match else { fatalError() }
                let arguments = arr[(i - Int(function.arity))..<i].map { element -> Expression in
                    guard case let .left(expression) = element else { fatalError() }
                    return expression
                }
                arr[(i - Int(function.arity))...i] = [.left(.function(function, arguments: arguments))]
                i -= Int(function.arity)
                i += 1
            }
        }
        
    }
    guard arr.count == 1, case let .left(expression) = arr[0] else { fatalError() }
    return expression
    
    // Crash if token type is a parentheses
}

extension Expression {
    init(_ string: String) throws {
//        do {
            let tokenizer = Tokenizer(using: TokenClassification.self)
            let tokens = try tokenizer.tokenize(string)
            let output = try postfixTokens(from: tokens)
            let expression = try createAST(from: output)
            self = expression
//        } catch let error as ParseError {
//            print(error.localizedDescription)
//            fatalError("Could not parse string to `Expression`.")
//        } catch {
//            fatalError("Could not parse string to `Expression`.")
//        }
    }
}

extension Expression: CustomStringConvertible {
    private var _description: String {
        switch self {
        case let .infixOperator(infixOperator, lhs, rhs):
            return "(\(lhs._description) \(infixOperator.identifier) \(rhs._description))"
            
        case let .postfixOperator(postfixOperator, expression):
            return expression._description + postfixOperator.identifier//"(" + expression._description + postfixOperator.identifier + ")"
        
        case let .prefixOperator(prefixOperator, expression):
            return prefixOperator.identifier + expression._description//"(" + prefixOperator.identifier + expression._description + ")"
        
        case let .function(function, arguments):
            return function.identifier + "(" + arguments.lazy.map(\.description).joined(separator: ", ") + ")"
            
        case let .constant(constant):
            return constant.identifier
            
        case let .number(number):
            return "\(number)"
        }
    }
    var description: String {
        return self._description.replacingOccurrences(of: "^\\((.+)\\)$", with: "$1", options: .regularExpression)
    }
}

func defineValuesForLookupTable() throws {
    try LookupTable.define(infixOperator: .init("+", precedence: 0) { $0 + $1 })
    try LookupTable.define(infixOperator: .init("-", precedence: 0) { $0 - $1 })
    try LookupTable.define(infixOperator: .init("*", precedence: 100) { $0 * $1 })
    try LookupTable.define(infixOperator: .init("/", precedence: 100) { $0 / $1 })
    try LookupTable.define(infixOperator: .init("^", associativity: .right, precedence: 200, function: pow))
    
    try LookupTable.define(prefixOperator: .init("-") { -$0 })
    try LookupTable.define(prefixOperator: .init("+") { $0 })
    
    try LookupTable.define(constant: .init("pi", value: .pi))
    try LookupTable.define(constant: .init("π", value: .pi))
    try LookupTable.define(constant: .init("e", value: M_E))
    try LookupTable.define(constant: .init("g", value: 9.81))
    try LookupTable.define(constant: .init("x", value: 0))

    
    try LookupTable.define(function: .init("cos", arity: 1) { cos($0[0]) })
    try LookupTable.define(function: .init("sin", arity: 1) { sin($0[0]) })
    try LookupTable.define(function: .init("tan", arity: 1) { tan($0[0]) })
    try LookupTable.define(function: .init("sec", arity: 1) { 1 / cos($0[0]) })
    try LookupTable.define(function: .init("csc", arity: 1) { 1 / sin($0[0]) })
    try LookupTable.define(function: .init("cot", arity: 1) { 1 / tan($0[0]) })
    try LookupTable.define(function: .init("acos", arity: 1) { acos($0[0]) })
    try LookupTable.define(function: .init("asin", arity: 1) { asin($0[0]) })
    try LookupTable.define(function: .init("atan", arity: 1) { atan($0[0]) })
    try LookupTable.define(function: .init("sqrt", arity: 1) { sqrt($0[0]) })
    try LookupTable.define(function: .init("cbrt", arity: 1) { cbrt($0[0]) })
    try LookupTable.define(function: .init("log", arity: 1) { log10($0[0]) })
    try LookupTable.define(function: .init("log2", arity: 1) { log2($0[0]) })
    try LookupTable.define(function: .init("ln", arity: 1) { log($0[0]) })
    try LookupTable.define(function: .init("exp", arity: 1) { Darwin.exp($0[0]) })
}
