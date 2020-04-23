import UIKit
//import SwiftUI


//#if !canImport(SwiftUI)
//public struct UnitPoint: Hashable {
//
//    public var x: CGFloat
//    public var y: CGFloat
//
//    @inlinable public init() {
//        self = UnitPoint.zero
//    }
//
//    @inlinable public init(x: CGFloat, y: CGFloat) {
//        self.x = x
//        self.y = y
//    }
//
//    public static let zero = UnitPoint(x: 0, y: 0)
//    public static let center = UnitPoint(x: 0.5, y: 0.5)
//    public static let leading = UnitPoint(x: 0, y: 0.5)
//    public static let trailing = UnitPoint(x: 1, y: 0.5)
//    public static let top = UnitPoint(x: 0.5, y: 0)
//    public static let bottom = UnitPoint(x: 0.5, y: 1)
//    public static let topLeading = UnitPoint(x: 0, y: 0)
//    public static let topTrailing = UnitPoint(x: 0, y: 1)
//    public static let bottomLeading = UnitPoint(x: 1, y: 1)
//    public static let bottomTrailing = UnitPoint(x: 1, y: 0)
//}
//#endif

// Namespace all view related things into their own property (e.g. style)
class Graph {
    var function: (Double) -> Double
    var line = Line(color: .black, width: 2)
    var backgroundColor: UIColor = .white
    var axisColor: UIColor = .black

    var xAxis = Axis()
    var yAxis = Axis()
    
    
//    var showHorizontalMinorGridLines: Bool = false
//    var showHorizontalMajorGridLines: Bool = false
//
//    var showVerticalMinorGridLines: Bool = false
//    var showVerticalMajorGridLines: Bool = false
//
//    var showHorizontalGridLines: Bool {
//        get {
//            return showHorizontalMinorGridLines && showHorizontalMajorGridLines
//        }
//        set {
//            showHorizontalMinorGridLines = newValue
//            showHorizontalMajorGridLines = newValue
//        }
//    }
//    var showVerticalGridLines: Bool {
//        get {
//            return showVerticalMinorGridLines && showVerticalMajorGridLines
//        }
//        set {
//            showVerticalMinorGridLines = newValue
//            showVerticalMajorGridLines = newValue
//        }
//    }
//
//    var showMinorGridLines: Bool {
//        get {
//            return showHorizontalMinorGridLines && showVerticalMinorGridLines
//        }
//        set {
//            showHorizontalMinorGridLines = newValue
//            showVerticalMinorGridLines = newValue
//        }
//    }
//    var showMajorGridLines: Bool {
//        get {
//            return showHorizontalMajorGridLines && showVerticalMajorGridLines
//        }
//        set {
//            showHorizontalMajorGridLines = newValue
//            showVerticalMajorGridLines = newValue
//        }
//    }
//
//    var showAllGridLines: Bool {
//        get {
//            return showMinorGridLines && showMajorGridLines
//        }
//        set {
//            showMinorGridLines = newValue
//            showMajorGridLines = newValue
//        }
//    }
    
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

    init(of function: @escaping (Double) -> Double) {
        self.function = function
    }
}

extension Graph {
    struct Line {
        var color: UIColor
        var width: Double
    }
}

extension Graph {
    struct Axis {
        var range: ClosedRange<Double> = -10...10

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

extension Graph {
    struct Point: Equatable {
        var x, y: Double
        var color = UIColor.red
        var showLabel = false

        static func ==(lhs: Point, rhs: Point) -> Bool {
            return lhs.x == rhs.x && lhs.y == rhs.y
        }
    }
}

extension Graph: CustomPlaygroundDisplayConvertible {
    var playgroundDescription: Any {
        return self.uiView
    }
}

extension CGSize {
    static func square(sideLength: Int) -> CGSize {
        return CGSize(width: sideLength, height: sideLength)
    }
    static func square(sideLength: Double) -> CGSize {
        return CGSize(width: sideLength, height: sideLength)
    }
    static func square(sideLength: CGFloat) -> CGSize {
        return CGSize(width: sideLength, height: sideLength)
    }
}

func adjust<T>(value: T, in range: ClosedRange<T>, toValueIn newRange: ClosedRange<T>) -> T where T: FloatingPoint {
    let distance1 = range.upperBound - range.lowerBound
    guard distance1 != 0 else {
        return newRange.lowerBound
    }
    
    let distance2 = newRange.upperBound - newRange.lowerBound
    let newValue = (value - range.lowerBound) * distance2 / distance1 + newRange.lowerBound
    
    return newValue
}

extension Graph {
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
            viewLength = Double(size.width)
        } else {
            graphLength = xAxis.distance
            viewLength = Double(size.height)
        }

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
            if 6...12 ~= graphLength / interval {
                boxDimension = adjust(value: interval, in: 0...graphLength, toValueIn: 0...viewLength)
                break
            }
        }
        return (dimension: boxDimension, interval: interval)
    }
}

extension Graph {
    enum Style {
        case dark, light
    }
    
    func applyStyle(_ style: Style) {
        switch style {
        case .dark:
            graph.backgroundColor = .clear
            graph.line.color = .white
            graph.axisColor = .white
        case .light:
            graph.backgroundColor = .white
            graph.line.color = .black
            graph.axisColor = .black
        }
    }
}

// Choose dimensions for graph
extension Graph {
    var uiView: UIView {
        
        var size = maxSize

        let xLength = xAxis.distance
        let yLength = yAxis.distance
        if xLength > yLength {
            size.height = CGFloat(yLength) * maxSize.width / CGFloat(xLength)
        } else {
            size.width = CGFloat(xLength) * maxSize.height / CGFloat(yLength)
        }
    
        let view = UIView()
        view.frame.size = size
        view.backgroundColor = backgroundColor

        // Add axes
        var box = (dimension: 0.0, interval: 0.0)

        if xAxis.showNumberLabels || yAxis.showNumberLabels || yAxis.showMinorGridLines || yAxis.showMajorGridLines || xAxis.showMinorGridLines || xAxis.showMajorGridLines {
            box = self.gridBox
        }

        // Draw x-axis
        do {
            let axisView = UIView()
            axisView.frame = view.frame
            axisView.backgroundColor = .clear
            
            let y = size.height - CGFloat(adjust(value: 0, in: yAxis.range, toValueIn: 0...Double(size.height)))
            let x1: CGFloat = 0
            let x2 = size.width

            let path = UIBezierPath()

            path.move(to: CGPoint(x: x1, y: y))
            path.addLine(to: CGPoint(x: x2, y: y))

            let layer = CAShapeLayer()
            
            layer.path = path.cgPath
            layer.fillColor = UIColor.clear.cgColor
            layer.strokeColor = axisColor.cgColor
            layer.lineWidth = 1
            layer.lineCap = .butt
            layer.allowsEdgeAntialiasing = true

            axisView.layer.addSublayer(layer)
            view.addSubview(axisView)
        }
        
        // Draw y-axis
        do {
            let axisView = UIView()
            axisView.frame = view.frame
            axisView.backgroundColor = .clear
            
            let x = CGFloat(adjust(value: 0, in: xAxis.range, toValueIn: 0...Double(size.width)))
            let y1 = CGFloat.zero
            let y2 = size.height
            
            let path = UIBezierPath()
            
            path.move(to: CGPoint(x: x, y: y1))
            path.addLine(to: CGPoint(x: x, y: y2))
                        
            let layer = CAShapeLayer()
            
            layer.path = path.cgPath
            layer.fillColor = UIColor.clear.cgColor
            layer.strokeColor = axisColor.cgColor
            layer.lineWidth = 1
            layer.lineCap = .butt
            layer.allowsEdgeAntialiasing = true

            axisView.layer.addSublayer(layer)
            view.addSubview(axisView)
        }
        
        var yAxisLabels = [(frame: CGRect, obstructedLines: Int)?]()
        var yAxisMaxObstructedLines = 0
        var xAxisLabels = [(frame: CGRect, obstructedLines: Int)]()
        var xAxisObstructedLines = [CGRect?]()

        // y-axis labels
        if yAxis.showNumberLabels {
            let labelsView = UIView()
            labelsView.frame = view.frame
            labelsView.backgroundColor = .clear
            
            let x = CGFloat(adjust(value: 0, in: xAxis.range, toValueIn: 0...Double(size.width)))
            let y = size.height - CGFloat(adjust(value: 0, in: yAxis.range, toValueIn: 0...Double(size.height)))
            let aboveAxisMajorCount = Int(floor(y / CGFloat(box.dimension)))
            let firstY = y - CGFloat(box.dimension) * floor(y / CGFloat(box.dimension))
  
            
            for (i, y) in stride(from: firstY, through: size.height, by: CGFloat(box.dimension)).enumerated() {
                let label = UILabel()
                let font = UIFont.systemFont(ofSize: 10)
                
                var text = "\(Double(aboveAxisMajorCount - i) * box.interval)"
                text = text.replacingOccurrences(of: "\\.0+$", with: "", options: .regularExpression) //((\\.\\d*?[^0]\\d*?)0+|\\.0+)$
                
                let textSize = NSString(string: text).size(withAttributes: [.font : font])
                
                label.frame.size.width = textSize.width
                label.frame.size.height = textSize.height
                label.frame.origin.x = x - label.frame.size.width - 4
                label.frame.origin.y = y - label.frame.size.height / 2
                
                if i == aboveAxisMajorCount {
                    label.frame.origin.y += label.frame.size.height / 2 + 4
                }
                if label.frame.minY < 0 || label.frame.maxY > size.height {
                    yAxisLabels.append(nil)
                    continue
                }
                
                label.text = text
                label.font = font
                label.textColor = axisColor
                label.textAlignment = .right
                
                let obstructedLines = Int(floor((label.frame.size.width + 6) / CGFloat(box.dimension / 5)))
                yAxisLabels.append((frame: label.frame, obstructedLines: obstructedLines))
                if obstructedLines > yAxisMaxObstructedLines {
                    yAxisMaxObstructedLines = obstructedLines
                }
                labelsView.addSubview(label)
                
            }
            view.addSubview(labelsView)

        }
        
        // x-axis labels
        if xAxis.showNumberLabels {
            let labelsView = UIView()
            labelsView.frame = view.frame
            labelsView.backgroundColor = .clear
            
            let x = CGFloat(adjust(value: 0, in: xAxis.range, toValueIn: 0...Double(size.width)))
            let y = size.height - CGFloat(adjust(value: 0, in: yAxis.range, toValueIn: 0...Double(size.height)))
            let aboveAxisMajorCount = Int(floor(x / CGFloat(box.dimension)))
            let aboveAxisMinorCount = Int(floor(x / CGFloat(box.dimension / 5)))

            let firstX = x.remainder(dividingBy: CGFloat(box.dimension))
            
            let extraMinorCount = aboveAxisMinorCount - aboveAxisMajorCount * 5
            xAxisObstructedLines.append(contentsOf: Array(repeating: nil, count: extraMinorCount + 1))
            
            for (i, x) in stride(from: firstX, through: size.width, by: CGFloat(box.dimension)).enumerated() {
                let label = UILabel()
                let font = UIFont.systemFont(ofSize: 10)
                
                var text = "\(Double(aboveAxisMajorCount - i) * box.interval)"
                text = text.replacingOccurrences(of: "\\.0+$", with: "", options: .regularExpression)
                
                let textSize = NSString(string: text).size(withAttributes: [.font : font])
                
                label.frame.size.width = textSize.width
                label.frame.size.height = textSize.height
                label.frame.origin.x = x - label.frame.size.width / 2
                label.frame.origin.y = y + 4
                
                if i == aboveAxisMajorCount {
                    xAxisObstructedLines.append(contentsOf: Array(repeating: nil, count: 5))
                    guard !yAxis.showNumberLabels else {
                        continue
                    }
                    label.frame.origin.y += label.frame.size.height / 2 + 4
                }
//                print(text)
                if label.frame.minX < 0 || label.frame.maxX > size.width {
//                    print("ignored")
                    xAxisObstructedLines.append(contentsOf: Array(repeating: nil, count: 5))
                    continue
                }
                
                label.text = text
                label.font = font
                label.textColor = axisColor
                label.textAlignment = .center
                let obstructedLines = Int((label.frame.size.width + 2) / CGFloat(box.dimension / 5 * 2)) / 2
                xAxisLabels.append((frame: label.frame, obstructedLines: obstructedLines + 1))
                if xAxisObstructedLines.count < obstructedLines / 2 + 1 {
                    let framesCount = obstructedLines + 1 - (obstructedLines / 2 + 1 - xAxisObstructedLines.count)
                    xAxisObstructedLines.removeAll()
                    xAxisObstructedLines.append(contentsOf: Array(repeating: label.frame, count: framesCount))
                    xAxisObstructedLines.append(contentsOf: Array(repeating: label.frame, count: obstructedLines + 1))
                } else {
                    xAxisObstructedLines.removeLast(obstructedLines / 2 + 1)
                    xAxisObstructedLines.append(contentsOf: Array(repeating: label.frame, count: obstructedLines + 1))
                }
                xAxisObstructedLines.append(contentsOf: Array(repeating: nil, count: 5 - obstructedLines / 2))
                labelsView.addSubview(label)
                
            }
            view.addSubview(labelsView)
        }

        // y-axis grid lines
        if yAxis.showMinorGridLines || yAxis.showMajorGridLines {
            let gridLineView = UIView()
            gridLineView.frame = view.frame
            gridLineView.backgroundColor = .clear
            
            let axisY = size.height - CGFloat(adjust(value: 0, in: yAxis.range, toValueIn: 0...Double(size.height)))
            let aboveAxisMinorCount = Int(floor(axisY / CGFloat(box.dimension / 5)))
            let firstY = axisY - CGFloat(box.dimension / 5) * floor(axisY / CGFloat(box.dimension / 5))//y.remainder(dividingBy: CGFloat(box.dimension / 5))
            
            for (i, y) in stride(from: firstY, through: size.height, by: CGFloat(box.dimension / 5)).enumerated() {//0..<Int(floor(size.height / CGFloat(boxDimension))) {
                let isMajorGridLine = abs(aboveAxisMinorCount - i).isMultiple(of: 5)
                guard i != aboveAxisMinorCount else {
                    continue
                }
                
                // No minor lines and isn't major
                if !yAxis.showMinorGridLines && !isMajorGridLine {
                    continue
                }
                
                if yAxis.showMinorGridLines || yAxis.showMajorGridLines {
                    var strokeColor: UIColor
                    var lineWidth: CGFloat
                    if isMajorGridLine && yAxis.showMajorGridLines {
                        lineWidth = 0.5
                        var white: CGFloat = 0
                        axisColor.getWhite(&white, alpha: nil)
                        white = white > 0.5 ? 0.75 : 0.25
                        strokeColor = UIColor(white: white, alpha: 1) //0.25
                    } else {
                        lineWidth = 0.25
                        strokeColor = UIColor(white: 0.5, alpha: 1) //0.5
                    }
                    
                    let path = UIBezierPath()
                    
                    path.move(to: CGPoint(x: 0, y: y))

                    if yAxis.showNumberLabels, isMajorGridLine, let labelFrame = yAxisLabels[i / 5]?.frame {
                        path.addLine(to: CGPoint(x: labelFrame.minX - 1, y: y))
                        path.move(to: CGPoint(x: labelFrame.maxX + 1, y: y))
                    }
                    if xAxis.showNumberLabels, i > aboveAxisMinorCount, let textHeight = xAxisLabels.first?.frame.height, axisY...(axisY + 4 + textHeight) ~= y {
                        for (labelFrame, _) in xAxisLabels {
                            path.addLine(to: CGPoint(x: labelFrame.minX - 1, y: y))
                            path.move(to: CGPoint(x: labelFrame.maxX + 1, y: y))
                        }
                    }
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    
                    let layer = CAShapeLayer()
                    
                    layer.path = path.cgPath
                    layer.fillColor = UIColor.clear.cgColor
                    layer.strokeColor = strokeColor.cgColor//UIColor.black.withAlphaComponent(0.8).cgColor
                    layer.lineWidth = lineWidth//0.75
                    layer.lineCap = .butt
                    layer.allowsEdgeAntialiasing = true

                    gridLineView.layer.addSublayer(layer)
                }
                
            }
            
            view.addSubview(gridLineView)
        }

        // x-axis grid lines
        if xAxis.showMinorGridLines || xAxis.showMajorGridLines {
            let gridLineView = UIView()
            gridLineView.frame = view.frame
            gridLineView.backgroundColor = .clear
            
            let x = CGFloat(adjust(value: 0, in: xAxis.range, toValueIn: 0...Double(size.width)))
            let y = size.height - CGFloat(adjust(value: 0, in: yAxis.range, toValueIn: 0...Double(size.height)))
            let aboveAxisMinorCount = Int(floor(x / CGFloat(box.dimension / 5)))
            let firstX = x.remainder(dividingBy: CGFloat(box.dimension / 5))
            for (i, x) in stride(from: firstX, through: size.width, by: CGFloat(box.dimension / 5)).enumerated() {
                let isMajorGridLine = abs(aboveAxisMinorCount - i).isMultiple(of: 5)
                
                // Not minor and isn't major
                if !xAxis.showMinorGridLines && !isMajorGridLine {
                    continue
                }
                
                guard i != aboveAxisMinorCount else {
                    continue
                }
                if xAxis.showMinorGridLines || xAxis.showMajorGridLines {
                    var strokeColor: UIColor
                    var lineWidth: CGFloat
                    if isMajorGridLine && xAxis.showMajorGridLines {
                        lineWidth = 0.5
                        var white: CGFloat = 0
                        axisColor.getWhite(&white, alpha: nil)
                        white = white > 0.5 ? 0.75 : 0.25
                        strokeColor = UIColor(white: white, alpha: 1) //0.25
                    } else {
                        lineWidth = 0.25
                        strokeColor = UIColor(white: 0.5, alpha: 1) //0.5
                    }
                    
                    let path = UIBezierPath()
                    
                    path.move(to: CGPoint(x: x, y: 0))
                    
                    let lineNumber = aboveAxisMinorCount - i
                    var frames = [CGRect]()

                    if yAxis.showNumberLabels && lineNumber > 0 && lineNumber <= yAxisMaxObstructedLines {
                        frames = Array(yAxisLabels.lazy.compactMap { $0 }.filter { $0.obstructedLines >= lineNumber }.map { $0.frame })

                        let aboveAxisFrames = frames.filter { $0.origin.y < y }
                        for frame in aboveAxisFrames {
                            path.addLine(to: CGPoint(x: x, y: frame.minY - 1))
                            path.move(to: CGPoint(x: x, y: frame.maxY + 1))
                        }
                    }
                    
                    if xAxis.showNumberLabels, let frame = xAxisObstructedLines[i] {
                        path.addLine(to: CGPoint(x: x, y: frame.minY - 1))
                        path.move(to: CGPoint(x: x, y: frame.maxY + 1))
                    }
                    if yAxis.showNumberLabels && lineNumber > 0 && lineNumber <= yAxisMaxObstructedLines {
                        let belowAxisFrames = frames.filter { $0.origin.y > y }
                        for frame in belowAxisFrames {
                            path.addLine(to: CGPoint(x: x, y: frame.minY - 1))
                            path.move(to: CGPoint(x: x, y: frame.maxY + 1))
                        }
                    }
                    
                    
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    
                    let layer = CAShapeLayer()
                    
                    layer.path = path.cgPath
                    layer.fillColor = UIColor.clear.cgColor
                    layer.strokeColor = strokeColor.cgColor//UIColor.black.withAlphaComponent(0.8).cgColor
                    layer.lineWidth = lineWidth//0.75
                    layer.lineCap = .butt
                    layer.allowsEdgeAntialiasing = true
                    
                    gridLineView.layer.addSublayer(layer)
                }
                
            }
            
            view.addSubview(gridLineView)
        }

        
        // Add function
        do {
            let functionView = UIView()
            functionView.frame = view.frame
            functionView.backgroundColor = .clear
            
            let step = abs(xAxis.max - xAxis.min) / 1000000
            let path = UIBezierPath()
            var hasPlacedFirstPoint = false
            
            for x in stride(from: xAxis.min, through: xAxis.max, by: step) {
                
                let y = function(x)
                
                if !yAxis.range.contains(y) {
                    continue
                }
                
                let adjX = adjust(value: x, in: xAxis.range, toValueIn: 0...Double(size.width))
                let adjY = Double(size.height) - adjust(value: y, in: yAxis.range, toValueIn: 0...Double(size.height))
                
                let p = CGPoint(x: adjX, y: adjY)
                
                if hasPlacedFirstPoint {
                    path.addLine(to: p)
                } else {
                    path.move(to: p)
                    hasPlacedFirstPoint = true
                }
                
            }
            
            
            let functionPathLayer = CAShapeLayer()
            functionPathLayer.path = path.cgPath
            functionPathLayer.fillColor = UIColor.clear.cgColor
            functionPathLayer.strokeColor = line.color.cgColor
            functionPathLayer.lineWidth = CGFloat(line.width)
            functionPathLayer.lineCap = .butt
            functionPathLayer.lineJoin = .round
            
            functionView.layer.addSublayer(functionPathLayer)
            
            view.addSubview(functionView)
        }
        
        return view
    }
}

func f(_ x: Double) -> Double {
    return x * x * x
}

var graph = Graph(of: f)
//graph.yAxis.min = 0
graph.maxSize = CGSize.square(sideLength: 1000)
graph.line.width = 3
graph.xAxis.range = -30...30
graph.yAxis.range = -20...20
graph.applyStyle(.dark)
graph
