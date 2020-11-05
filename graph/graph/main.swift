//
//  main.swift
//  graph
//
//  Created by Noah Wilder on 2020-04-23.
//  Copyright © 2020 Noah Wilder. All rights reserved.
//

import Foundation
import Cocoa
import ArgumentParser


class FunctionGraph {
    var function: (Double) -> Double?
    var line = Line(color: .black, width: 2.5)
    var backgroundColor: NSColor = .white
    var axisColor: NSColor = .black
    
    var xAxis = Axis()
    var yAxis = Axis()
    
//    var gridBoxDimensionRange: ClosedRange<Double> = 50...100
    
    var showMinorGridLines: Bool {
        get {
            return yAxis.showMinorGridLines && xAxis.showMinorGridLines
        }
        set {
            yAxis.showMinorGridLines = newValue
            xAxis.showMinorGridLines = newValue
        }
    }
    var showMajorGridLines: Bool {
        get {
            return yAxis.showMajorGridLines && xAxis.showMajorGridLines
        }
        set {
            yAxis.showMajorGridLines = newValue
            xAxis.showMajorGridLines = newValue
        }
    }
    
    var showAllGridLines: Bool {
        get {
            return showMinorGridLines && showMajorGridLines
        }
        set {
            showMinorGridLines = newValue
            showMajorGridLines = newValue
        }
    }
    
    var showAllNumberLabels: Bool {
        get {
            return xAxis.showNumberLabels && yAxis.showNumberLabels
        }
        set {
            xAxis.showNumberLabels = newValue
            yAxis.showNumberLabels = newValue
        }
    }
    //    var originLocation: UnitPoint = .center
    
    var points = [Point]()
    
    var maxSize = CGSize(width: 500, height: 500)
    
    init(of function: Expression) {
        self.function = { x in
            try! LookupTable.updateConstant(withIdentifier: "x", to: x)
            return function.evaluated()
        }
    }
    init(of function: @escaping (Double) -> Double?) {
        self.function = function
    }
    init(of function: @escaping (Double) -> Double) {
        self.function = function
    }
}

extension FunctionGraph {
    struct Line {
        var color: NSColor
        var width: Double
    }
}

extension FunctionGraph {
    struct Axis {
        var range: ClosedRange<Double> = -50...50
        var showNumberLabels = true
        var showMinorGridLines = true
        var showMajorGridLines = true
        
        var showAllGridLines: Bool {
            get {
                return showMinorGridLines && showMajorGridLines
            }
            set {
                showMinorGridLines = newValue
                showMajorGridLines = newValue
            }
        }
        
        var min: Double {
            get {
                return range.lowerBound
            }
            set {
                guard newValue < range.upperBound else {
                    fatalError("Axis min cannot be greater than max.")
                }
                range = newValue...range.upperBound
            }
        }
        
        var max: Double {
            get {
                return range.upperBound
            }
            set {
                guard newValue > range.lowerBound else {
                    fatalError("Axis max cannot be less than min.")
                }
                range = range.lowerBound...newValue
            }
        }
        
        var distance: Double {
            return abs(min - max)
        }
    }
}

extension FunctionGraph {
    struct Point: Equatable {
        var x, y: Double
        var color = NSColor.red
        var showLabel = false
        
        static func ==(lhs: Point, rhs: Point) -> Bool {
            return lhs.x == rhs.x && lhs.y == rhs.y
        }
    }
}
//let a = 5.0
//let b = a.adjusted(fromValueIn: 0...10, toValueIn: 0...20)
//print(b)
//// Prints "10.0"
////extension FunctionGraph: CustomPlaygroundDisplayConvertible {
////    var playgroundDescription: Any {
////        return self.uiView
////    }
////}
////
extension CGSize {
    var minDimension: CGFloat {
        return min(width, height)
    }
    
    var maxDimension: CGFloat {
        return max(width, height)
    }
}
extension FunctionGraph {
    private var gridBox: (dimension: Double, interval: Double) {
        var size = maxSize
        let xLength = xAxis.distance
        let yLength = yAxis.distance
        if xLength > yLength {
            size.height = CGFloat(yLength) * maxSize.width / CGFloat(xLength)
        } else {
            size.width = CGFloat(xLength) * maxSize.height / CGFloat(yLength)
        }
        
        let graphLength: Double
        let viewLength: Double
        if xAxis.distance > yAxis.distance {
            graphLength = yAxis.distance
            viewLength = Double(size.height)
        } else {
            graphLength = xAxis.distance
            viewLength = Double(size.width)
        }
//        let sizeMin = size.minDimension
        let sizeMax = size.maxDimension
//        let graphSize = CGSize(width: xAxis.distance, height: yAxis.distance)
//        let graphMin = graphSize.minDimension
//        let graphMax = graphSize.maxDimension

        
        var magnitude = pow(10, ceil(log10(graphLength)))//1.0
        var interval = magnitude
        var boxDimension = 0.0
        
        for i in 1... {
            switch i % 3 {
            case 0:
                magnitude /= 10
                interval = magnitude
            case 1:
                interval /= 2
            case 2:
                interval -= 3 * (magnitude / 10)
            default:
                break
            }
            boxDimension = interval.adjusted(fromValueIn: 0...graphLength, toValueIn: 0...viewLength)
            if 5...12 ~= sizeMax / CGFloat(boxDimension), //gridBoxDimensionRange ~= boxDimension,
                Double(size.width) / boxDimension * interval >= xAxis.distance,
                Double(size.height) / boxDimension * interval >= yAxis.distance
            {
                break
            }
            //            if 6...12 ~= graphLength / interval {
            //                boxDimension = adjust(value: interval, in: 0...graphLength, toValueIn: 0...viewLength)
            //                break
            //            }
        }
        return (dimension: boxDimension, interval: interval)
    }
}

extension FunctionGraph {
    enum Style: String, ExpressibleByArgument {
        case dark, light, terminal
    }
    
    func applyStyle(_ style: Style) {
        switch style {
        case .dark:
            backgroundColor = .clear
            line.color = .white
            axisColor = .white
        case .light:
            backgroundColor = .white
            line.color = .black
            axisColor = .black
        case .terminal:
            backgroundColor = NSColor.clear
            axisColor = NSColor(srgbRed: 0 / 255, green: 194 / 255, blue: 1 / 255, alpha: 1)
            line.color = NSColor(srgbRed: 0.7800917029, green: 0.7696406245, blue: 0, alpha: 1) //#colorLiteral(red: 1, green: 0.4665257931, blue: 0.9988340735, alpha: 1)//.cyan //axisColor
        }
    }
}

//TODO: Be sure to flip nsview
//
//// Choose dimensions for graph
extension NSBezierPath {
    
    /// A `CGPath` object representing the current `NSBezierPath`.
    var cgPath: CGPath {
        let path = CGMutablePath()
        let points = UnsafeMutablePointer<NSPoint>.allocate(capacity: 3)
        let elementCount = self.elementCount
        
        if elementCount > 0 {
            var didClosePath = true
            
            for index in 0..<elementCount {
                let pathType = self.element(at: index, associatedPoints: points)
                
                switch pathType {
                case .moveTo:
                    path.move(to: CGPoint(x: points[0].x, y: points[0].y))
                case .lineTo:
                    path.addLine(to: CGPoint(x: points[0].x, y: points[0].y))
                    didClosePath = false
                case .curveTo:
                    let control1 = CGPoint(x: points[1].x, y: points[1].y)
                    let control2 = CGPoint(x: points[2].x, y: points[2].y)
                    path.addCurve(to: CGPoint(x: points[0].x, y: points[0].y), control1: control1, control2: control2)
                    didClosePath = false
                case .closePath:
                    path.closeSubpath()
                    didClosePath = true
                @unknown default:
                    fatalError()
                }
            }
            
            if !didClosePath { path.closeSubpath() }
        }
        
        points.deallocate()
        return path
    }
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
}

extension NSView {
    func createPNG(at url: URL) throws {
        let rep = bitmapImageRepForCachingDisplay(in: bounds)!
        cacheDisplay(in: bounds, to: rep)
        if let data = rep.representation(using: .png, properties: [:]) {
            try data.write(to: url)
        }
    }
}
public extension CGRect {
    /// The center point of a frame.
    var center: CGPoint {
        get {
            return CGPoint(x: origin.x + (size.width / 2), y: origin.y + (size.height / 2))
        }
        set (point) {
            origin.y = point.y - (size.height / 2)
            origin.x = point.x - (size.width / 2)
        }
    }
}

extension NSColor {
    
    func lighter(by percentage: CGFloat = 30.0) -> NSColor {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage: CGFloat = 30.0) -> NSColor {
        return self.adjust(by: -1 * abs(percentage))
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> NSColor {
        let red = redComponent
        let green = greenComponent
        let blue = blueComponent
        let alpha = alphaComponent
        
        return NSColor(srgbRed: min(red + percentage / 100, 1.0),
                       green: min(green + percentage / 100, 1.0),
                       blue: min(blue + percentage / 100, 1.0),
                       alpha: alpha)
    }
    
    func isLight() -> Bool {
        return (redComponent * 299 + greenComponent * 587 + blueComponent * 114) / 1000 > 125
    }
}
class FlippedView: NSView {
    override var isFlipped: Bool {
        return true
    }
}
    
extension FunctionGraph {
    var nsView: NSView {
        
        var size = maxSize
                
        let xLength = xAxis.distance
        let yLength = yAxis.distance
        if xLength > yLength {
            size.height = CGFloat(yLength) * maxSize.width / CGFloat(xLength)
        } else {
            size.width = CGFloat(xLength) * maxSize.height / CGFloat(yLength)
        }
        
        let axisColor = self.axisColor.withAlphaComponent(0.7)
        
        let view = FlippedView(frame: NSRect(x: 0, y: 0, width: size.width, height: size.height))
        view.wantsLayer = true
        view.layer?.backgroundColor = backgroundColor.cgColor
        
        // Add axes
        var box = (dimension: 0.0, interval: 0.0)
        
        if xAxis.showNumberLabels || yAxis.showNumberLabels || yAxis.showMinorGridLines || yAxis.showMajorGridLines || xAxis.showMinorGridLines || xAxis.showMajorGridLines {
            box = self.gridBox
        }
        
        var origin = CGPoint()
        origin.x = CGFloat(0.0.adjusted(fromValueIn: xAxis.range, toValueIn: 0...Double(size.width)))
        origin.y = size.height - CGFloat(0.adjusted(fromValueIn: yAxis.range, toValueIn: 0...Double(size.height)))
        
        // Draw axes
        do {
            let axisView = FlippedView(frame: view.frame)
            axisView.wantsLayer = true
            axisView.layer?.backgroundColor = NSColor.clear.cgColor

            let path = NSBezierPath()
            
            // x-axis
            path.move(to: CGPoint(x: 0, y: origin.y))
            path.line(to: CGPoint(x: size.width, y: origin.y))
            
            // y-axis
            path.move(to: CGPoint(x: origin.x, y: 0))
            path.line(to: CGPoint(x: origin.x, y: size.height))
            
            let layer = CAShapeLayer()
            
            layer.path = path.cgPath
            layer.fillColor = NSColor.clear.cgColor
            layer.strokeColor = axisColor.cgColor
            layer.lineWidth = 1
            layer.lineCap = .butt
            layer.allowsEdgeAntialiasing = true
            
            axisView.layer?.addSublayer(layer)
            view.addSubview(axisView)
        }
        
        let labelsPath = NSBezierPath()
        
        // y-axis labels
        if yAxis.showNumberLabels {
            let labelsView = FlippedView(frame: view.frame)
            labelsView.wantsLayer = true
            labelsView.layer?.backgroundColor = NSColor.clear.cgColor
            
            let aboveAxisMajorCount = Int(floor(origin.y / CGFloat(box.dimension)))
            let firstY = origin.y - CGFloat(box.dimension) * floor(origin.y / CGFloat(box.dimension))
            
            
            for (i, y) in stride(from: firstY, through: size.height, by: CGFloat(box.dimension)).enumerated() {
                let label = NSTextField()
                let font = NSFont.systemFont(ofSize: 10)
                
                var text = "\(Double(aboveAxisMajorCount - i) * box.interval)"
                text = text.replacingOccurrences(of: "\\.0+$", with: "", options: .regularExpression) //((\\.\\d*?[^0]\\d*?)0+|\\.0+)$
                
                let textSize = NSString(string: text).size(withAttributes: [.font : font])
                
                var labelFrame = CGRect()
                labelFrame.size.width = textSize.width
                labelFrame.size.height = textSize.height
                labelFrame.origin.x = origin.x - labelFrame.size.width - 4
                labelFrame.origin.y = y - labelFrame.size.height / 2
                
                if i == aboveAxisMajorCount {
                    labelFrame.origin.y += labelFrame.size.height / 2 + 4
                }
                if labelFrame.minY < 0 || labelFrame.maxY > size.height {
                    continue
                }
                let path = NSBezierPath(rect: labelFrame.padding(1))
                labelsPath.append(path)
                
                label.frame = labelFrame
                
                label.stringValue = text
                label.font = font
                label.backgroundColor = NSColor.clear
                label.textColor = axisColor
                label.isBezeled = false
                label.isEditable = false
                label.alignment = .center
                label.sizeToFit()
                label.frame.center = labelFrame.center
                
                labelsView.addSubview(label)
                
            }
            view.addSubview(labelsView)
            
        }
        
        // x-axis labels
        if xAxis.showNumberLabels {
            let labelsView = FlippedView(frame: view.frame)
            labelsView.wantsLayer = true
            labelsView.layer?.backgroundColor = NSColor.clear.cgColor
            
            let beforeAxisMajorCount = Int(floor(origin.x / CGFloat(box.dimension)))
            let firstX = origin.x.remainder(dividingBy: CGFloat(box.dimension))
            
            for (i, x) in stride(from: firstX, through: size.width, by: CGFloat(box.dimension)).enumerated() {
                let label = NSTextField()
                let font = NSFont.systemFont(ofSize: 10)
                
                var text = "\(-Double(beforeAxisMajorCount - i) * box.interval)"
                text = text.replacingOccurrences(of: "\\.0+$", with: "", options: .regularExpression)
                
                let textSize = NSString(string: text).size(withAttributes: [.font : font])
                
                var labelFrame = CGRect()

                labelFrame.size.width = textSize.width
                labelFrame.size.height = textSize.height
                labelFrame.origin.x = x - labelFrame.size.width / 2
                labelFrame.origin.y = origin.y + 4
                
                if i == beforeAxisMajorCount {
                    guard !yAxis.showNumberLabels else {
                        continue
                    }
                    labelFrame.origin.y += labelFrame.size.height / 2 + 4
                }
                
                if labelFrame.minX < 0 || labelFrame.maxX > size.width {
                    continue
                }
                
                let path = NSBezierPath(rect: labelFrame.padding(1))
                labelsPath.append(path)
                
                label.frame = labelFrame
                
                label.stringValue = text
                label.font = font
                label.textColor = axisColor
                label.backgroundColor = NSColor.clear
                label.isBezeled = false
                label.isEditable = false
                label.alignment = .center
                label.sizeToFit()
                label.frame.center = labelFrame.center
                
                labelsView.addSubview(label)
            }
            view.addSubview(labelsView)
        }
        
        let minorGridLinesPath = NSBezierPath()
        let majorGridLinesPath = NSBezierPath()
        
        // y-axis grid lines
        if yAxis.showMinorGridLines || yAxis.showMajorGridLines {
            let gridLineView = FlippedView(frame: view.frame)
            gridLineView.wantsLayer = true
            gridLineView.layer?.backgroundColor = NSColor.clear.cgColor
            
            let aboveAxisMinorCount = Int(floor(origin.y / CGFloat(box.dimension / 5)))
            let firstY = origin.y - CGFloat(box.dimension / 5) * floor(origin.y / CGFloat(box.dimension / 5))  // origin.y.remainder(dividingBy: CGFloat(box.dimension / 5))
            
            for (i, y) in stride(from: firstY, through: size.height, by: CGFloat(box.dimension / 5)).enumerated() { //0..<Int(floor(size.height / CGFloat(boxDimension))) {
                let isMajorGridLine = abs(aboveAxisMinorCount - i).isMultiple(of: 5)
                guard i != aboveAxisMinorCount else {
                    continue
                }
                
                // No minor lines and isn't major
                if !yAxis.showMinorGridLines && !isMajorGridLine {
                    continue
                }
                
                let path = NSBezierPath()
                path.move(to: CGPoint(x: 0, y: y))
                path.line(to: CGPoint(x: size.width, y: y))
                
                if isMajorGridLine && yAxis.showMajorGridLines {
                    majorGridLinesPath.append(path)
                } else {
                    minorGridLinesPath.append(path)
                }
            }
        }
        
        // x-axis grid lines
        if xAxis.showMinorGridLines || xAxis.showMajorGridLines {
            let gridLineView = FlippedView(frame: view.frame)
            gridLineView.wantsLayer = true
            gridLineView.layer?.backgroundColor = NSColor.clear.cgColor
            
            let beforeAxisMinorCount = Int(floor(origin.x / CGFloat(box.dimension / 5)))
            let firstX = origin.x.remainder(dividingBy: CGFloat(box.dimension / 5))
            for (i, x) in stride(from: firstX, through: size.width, by: CGFloat(box.dimension / 5)).enumerated() {
                let isMajorGridLine = abs(beforeAxisMinorCount - i).isMultiple(of: 5)
                
                // Not minor and isn't major
                if !xAxis.showMinorGridLines && !isMajorGridLine {
                    continue
                }
                
                guard i != beforeAxisMinorCount else {
                    continue
                }
                
                let path = NSBezierPath()
                path.move(to: CGPoint(x: x, y: 0))
                path.line(to: CGPoint(x: x, y: size.height))
                
                if isMajorGridLine && xAxis.showMajorGridLines {
                    majorGridLinesPath.append(path)
                } else {
                    minorGridLinesPath.append(path)
                }
            }
        }
        
        
        if xAxis.showMinorGridLines || xAxis.showMajorGridLines || yAxis.showMinorGridLines || yAxis.showMajorGridLines {
            let textLayer = CAShapeLayer()
            labelsPath.append(NSBezierPath(rect: view.frame))
            textLayer.path = labelsPath.cgPath
            textLayer.fillRule = .evenOdd
            
            let gridColor = axisColor.usingColorSpace(.genericRGB) ?? .white
            let isLightColor = gridColor.isLight()
            var majorAxisColor = isLightColor ? gridColor.darker(by: 25) : gridColor.lighter(by: 25)
            var minorAxisColor = isLightColor ? gridColor.darker(by: 50) : gridColor.lighter(by: 50)

            majorAxisColor = majorAxisColor.withAlphaComponent(majorAxisColor.alphaComponent - 0.1)
            minorAxisColor = minorAxisColor.withAlphaComponent(minorAxisColor.alphaComponent - 0.1)

//            var white: CGFloat = 0
//            axisColor.getWhite(&white, alpha: nil)
//            let majorWhite: CGFloat = white > 0.5 ? 0.75 : 0.25
            
            let majorGridLayer = CAShapeLayer()
            majorGridLayer.path = majorGridLinesPath.cgPath
            majorGridLayer.fillColor = NSColor.clear.cgColor
            majorGridLayer.strokeColor = majorAxisColor.cgColor //NSColor(white: majorWhite, alpha: 1).cgColor
            majorGridLayer.lineWidth = 0.5
            majorGridLayer.lineCap = .butt
            majorGridLayer.allowsEdgeAntialiasing = true
            
            let minorGridLayer = CAShapeLayer()
            minorGridLayer.path = minorGridLinesPath.cgPath
            minorGridLayer.fillColor = NSColor.clear.cgColor
            minorGridLayer.strokeColor = minorAxisColor.cgColor //NSColor(white: 0.5, alpha: 1).cgColor
            minorGridLayer.lineWidth = 0.25
            minorGridLayer.lineCap = .butt
            minorGridLayer.allowsEdgeAntialiasing = true
            
            let gridView = FlippedView(frame: view.frame)
            gridView.wantsLayer = true
            gridView.layer?.backgroundColor = .clear
            gridView.layer?.addSublayer(minorGridLayer)
            gridView.layer?.addSublayer(majorGridLayer)
            gridView.layer?.mask = textLayer
            
            view.addSubview(gridView)
        }
        
        // Add function
        do {
            let functionView = FlippedView(frame: view.frame)
            functionView.wantsLayer = true
            functionView.layer?.backgroundColor = NSColor.clear.cgColor
            
            let numberOfSteps = Double(size.width) * 500 //xAxis.distance * 100
            let step = abs(xAxis.max - xAxis.min) / numberOfSteps //1000000
            let path = NSBezierPath()
            var movePoint = true
            var previousPoint: CGPoint?

            for x in stride(from: xAxis.min, through: xAxis.max, by: step) {

                guard let y = function(x) else {
                    movePoint = true
                    continue
                }

                if !yAxis.range.contains(y) {
                    continue
                }

                let adjX = x.adjusted(fromValueIn: xAxis.range, toValueIn: 0...Double(size.width))
                let adjY = Double(size.height) - y.adjusted(fromValueIn: yAxis.range, toValueIn: 0...Double(size.height))

                let p2 = CGPoint(x: adjX, y: adjY)
                
                if let p1 = previousPoint, p1.distance(to: p2) > 1 {
                    movePoint = true
                }

                previousPoint = p2
                
                if movePoint {
                    path.move(to: p2)
                    movePoint = false
                } else {
                    path.line(to: p2)
                }
            }
            
            path.move(to: path.currentPoint)
            
            let functionPathLayer = CAShapeLayer()
            functionPathLayer.path = path.cgPath
            functionPathLayer.fillColor = NSColor.clear.cgColor
            functionPathLayer.strokeColor = line.color.cgColor
            functionPathLayer.lineWidth = CGFloat(line.width)
            functionPathLayer.lineCap = .butt
            functionPathLayer.lineJoin = .round
            
            functionView.layer?.addSublayer(functionPathLayer)
            
            view.addSubview(functionView)
        }
        
        return view
    }
}
//extension FloatingPoint {
//    public func isAlmostEqual(
//        to other: Self,
//        tolerance: Self = Self.ulpOfOne.squareRoot()
//    ) -> Bool {
//        assert(tolerance >= .ulpOfOne && tolerance < 1, "tolerance should be in [.ulpOfOne, 1).")
//        guard self.isFinite && other.isFinite else {
//            return rescaledAlmostEqual(to: other, tolerance: tolerance)
//        }
//        let scale = max(abs(self), abs(other), .leastNormalMagnitude)
//        return abs(self - other) < scale*tolerance
//    }
//    
//    public func isAlmostZero(
//        absoluteTolerance tolerance: Self = Self.ulpOfOne.squareRoot()
//    ) -> Bool {
//        assert(tolerance > 0)
//        return abs(self) < tolerance
//    }
//    
//    @usableFromInline
//    internal func rescaledAlmostEqual(to other: Self, tolerance: Self) -> Bool {
//        if self.isNaN || other.isNaN { return false }
//        if self.isInfinite {
//            if other.isInfinite { return self == other }
//            let scaledSelf = Self(sign: self.sign,
//                                  exponent: Self.greatestFiniteMagnitude.exponent,
//                                  significand: 1)
//            let scaledOther = Self(sign: .plus,
//                                   exponent: -1,
//                                   significand: other)
//            return scaledSelf.isAlmostEqual(to: scaledOther, tolerance: tolerance)
//        }
//        return other.rescaledAlmostEqual(to: self, tolerance: tolerance)
//    }
//}
//
//extension Double {
//    static let e = M_E
//}
//

//var exp = Expression("3 + (7 ^ 2 * (49 - 21) / (6 + 1) - (4 * (2 + 5))) - 2 * (7 * 5) ^ 2", simplify: false)
//print(exp.evaluate())
//
//let eq = Expression("x^2", simplify: false)
//let graph = FunctionGraph(of: eq)
//let view = graph.nsView
//let homeDir = FileManager.default.homeDirectoryForCurrentUser
//let currentDir = homeDir.appendingPathComponent("Desktop/Testing")
//let imageURL = currentDir.appendingPathComponent("graph.png")
//
//do {
//    try view.createPNG(at: imageURL)
//    print("FunctionGraph image created.")
//} catch {
//    print(error.localizedDescription)
//    exit(0)
//}



//@discardableResult
//func shell(_ args: String...) -> Int32 {
//    let task = Process()
//    task.launchPath = "/usr/bin/env"
//    task.arguments = args
//    task.launch()
//    task.waitUntilExit()
//    return task.terminationStatus
//}
@discardableResult func shell(_ command: String) -> (String?, Int32) {
    let task = Process()
    
    task.launchPath = "/bin/zsh"
    task.arguments = ["-c", command]
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)
    task.waitUntilExit()
    return (output, task.terminationStatus)
}
extension ClosedRange: ExpressibleByArgument where Bound == Double {
    public init?(argument: String) {
        let regex = #"^[\+-]?\d+(\.\d+)?\.\.\.[\+-]?\d+(\.\d+)?$"#
        guard let _ = argument.range(of: regex, options: .regularExpression) else {
            return nil
        }
        let bounds = argument
            .components(separatedBy: "...")
            .compactMap { Bound($0) }
        
        guard bounds.count == 2 else { return nil }
        
        self = ClosedRange(uncheckedBounds: (lower: bounds[0], upper: bounds[1]))
    }
}

struct Graph: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "A tool that displays an in-line graph for a function.")
    
    @Argument(help: "The equation to graph.")
    var equation: String
    
    @Option(name: .long, default: -10...10, parsing: .scanningForValue, help: "The range of the x-axis.")
    var xrange: ClosedRange<Double>

    @Option(name: .long, default: -10...10, parsing: .scanningForValue, help: "The range of the y-axis.")
    var yrange: ClosedRange<Double>
    
    @Option(name: .shortAndLong, default: 2, parsing: .scanningForValue, help: "The line width of the function.")
    var lineWidth: Double
    
    @Flag(name: .long, default: true, inversion: .prefixedNo, help: "Whether or not to show the grid.")
    var grid: Bool
    
    @Flag(name: .long, default: true, inversion: .prefixedNo, help: "Whether or not to show number labels.")
    var labels: Bool
    
    @Option(name: .long, default: .terminal, parsing: .scanningForValue, help: "The style of the graph. Either `dark`, `light`, or `terminal`.")
    var style: FunctionGraph.Style
    
    enum ValidationError: Error {
        case emptyEquation
    }
    mutating func validate() throws {
        if equation.isEmpty {
            throw ValidationError.emptyEquation
        }
      // [equation.joined(separator: " ").replacingOccurrences(of: #"(y|[a-zA-Z]\(x\))\s*=\s*"#, with: "")]
    }
    
    func run() throws {
//        guard let eq = equation.first else {
//            return
//        }
        try defineValuesForLookupTable()
        
        
        
        
        let formattedEquation = equation.replacingOccurrences(of: #"^([yY]|[a-zA-Z]\([xX]\))\s*=\s*"#, with: "", options: .regularExpression)

        let expression: Expression
        do {
            expression = try Expression(formattedEquation)
        } catch let error as ParseError {
            print(error.localizedDescription)
            return
        }
        
        let graph = FunctionGraph(of: expression)
        graph.maxSize = CGSize(width: 400, height: 400)
        graph.line.width = lineWidth
        graph.xAxis.range = xrange// ?? -50...50
        graph.yAxis.range = yrange// ?? -50...50
        graph.showAllGridLines = grid
        graph.showAllNumberLabels = labels
//        graph.gridBoxDimensionRange = 50...75
        graph.applyStyle(style)
        let view = graph.nsView
        let homeDir = URL(fileURLWithPath: "/tmp")
//        let currentDir = homeDir.appendingPathComponent("Desktop/Testing")
        let imageURL = homeDir.appendingPathComponent(".graph.png")
        
        if FileManager.default.fileExists(atPath: imageURL.path) {
            try FileManager.default.removeItem(at: imageURL)
        }
        try view.createPNG(at: imageURL)
//        print()

//        let _ = shell("imgcat ~/Desktop/Testing/graph.png")
//        try FileManager.default.removeItem(at: imageURL)


    }
}
////shell("xcodebuild", "-workspace", "myApp.xcworkspace")

Graph.main()
//#alias graph="~/Desktop/Coding/Coding\ Projects/Graphing/graph/bin/graph"
//
//#alias graph="~/Desktop/Coding/Coding\ Projects/Graphing/graph/bin/graph '$1' && imgcat ~/Desktop/Testing/graph.png && rm ~/Desktop/Testing/graph.png"
//# alias ohmyzsh="mate ~/.oh-my-zsh"
//#graph() {
//    #  eval "$(echo $@)"
//    #~/Desktop/Coding/Coding\ Projects/Graphing/graph/bin/graph "$@" &&
//    #       imgcat ~/Desktop/Testing/graph.png &&
//    #       rm ~/Desktop/Testing/graph.png
//    #}
//graph() {
//    echo "$@"
//}

