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
extension CGRect {
    func addPadding(_ width: CGFloat) -> CGRect {
        var rect = self
        rect.origin.x -= width
        rect.origin.y -= width
        rect.size.width += 2 * width
        rect.size.height += 2 * width
        return rect
    }
}
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
            viewLength = Double(size.height)
        } else {
            graphLength = xAxis.distance
            viewLength = Double(size.width)
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
            boxDimension = adjust(value: interval, in: 0...graphLength, toValueIn: 0...viewLength)
            if 50...100 ~= boxDimension,
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
        
        let labelsPath = UIBezierPath()
        
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
                    continue
                }
                let path = UIBezierPath(rect: label.frame.addPadding(1))
                labelsPath.append(path)
                
                label.text = text
                label.font = font
                label.textColor = axisColor
                label.textAlignment = .right
                
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

            let firstX = x.remainder(dividingBy: CGFloat(box.dimension))
                        
            for (i, x) in stride(from: firstX, through: size.width, by: CGFloat(box.dimension)).enumerated() {
                let label = UILabel()
                let font = UIFont.systemFont(ofSize: 10)
                
                var text = "\(-Double(aboveAxisMajorCount - i) * box.interval)"
                text = text.replacingOccurrences(of: "\\.0+$", with: "", options: .regularExpression)
                
                let textSize = NSString(string: text).size(withAttributes: [.font : font])
                
                label.frame.size.width = textSize.width
                label.frame.size.height = textSize.height
                label.frame.origin.x = x - label.frame.size.width / 2
                label.frame.origin.y = y + 4
                
                if i == aboveAxisMajorCount {
                    guard !yAxis.showNumberLabels else {
                        continue
                    }
                    label.frame.origin.y += label.frame.size.height / 2 + 4
                }

                if label.frame.minX < 0 || label.frame.maxX > size.width {
                    continue
                }
                
                let path = UIBezierPath(rect: label.frame.addPadding(1))
                labelsPath.append(path)
                
                label.text = text
                label.font = font
                label.textColor = axisColor
                label.textAlignment = .center
                
                labelsView.addSubview(label)
            }
            view.addSubview(labelsView)
        }

        let minorGridLinesPath = UIBezierPath()
        let majorGridLinesPath = UIBezierPath()

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
                
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                
                if isMajorGridLine && yAxis.showMajorGridLines {
                    majorGridLinesPath.append(path)
                } else {
                    minorGridLinesPath.append(path)
                }
            }
        }

        // x-axis grid lines
        if xAxis.showMinorGridLines || xAxis.showMajorGridLines {
            let gridLineView = UIView()
            gridLineView.frame = view.frame
            gridLineView.backgroundColor = .clear
            
            let x = CGFloat(adjust(value: 0, in: xAxis.range, toValueIn: 0...Double(size.width)))
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
                
                let path = UIBezierPath()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))

                if isMajorGridLine && xAxis.showMajorGridLines {
                    majorGridLinesPath.append(path)
                } else {
                    minorGridLinesPath.append(path)
                }
            }
        }
        
        
        if xAxis.showMinorGridLines || xAxis.showMajorGridLines || yAxis.showMinorGridLines || yAxis.showMajorGridLines {
            let textLayer = CAShapeLayer()
            labelsPath.append(UIBezierPath(rect: view.frame))
            textLayer.path = labelsPath.cgPath
            textLayer.fillRule = .evenOdd
            
            var white: CGFloat = 0
            axisColor.getWhite(&white, alpha: nil)
            let majorWhite: CGFloat = white > 0.5 ? 0.75 : 0.25
            
            let majorGridLayer = CAShapeLayer()
            majorGridLayer.path = majorGridLinesPath.cgPath
            majorGridLayer.fillColor = UIColor.clear.cgColor
            majorGridLayer.strokeColor = UIColor(white: majorWhite, alpha: 1).cgColor
            majorGridLayer.lineWidth = 0.5
            majorGridLayer.lineCap = .butt
            majorGridLayer.allowsEdgeAntialiasing = true
            
            let minorGridLayer = CAShapeLayer()
            minorGridLayer.path = minorGridLinesPath.cgPath
            minorGridLayer.fillColor = UIColor.clear.cgColor
            minorGridLayer.strokeColor = UIColor(white: 0.5, alpha: 1).cgColor
            minorGridLayer.lineWidth = 0.25
            minorGridLayer.lineCap = .butt
            minorGridLayer.allowsEdgeAntialiasing = true
            
            let gridView = UIView()
            gridView.frame = view.frame
            gridView.backgroundColor = .clear
            gridView.layer.addSublayer(minorGridLayer)
            gridView.layer.addSublayer(majorGridLayer)
            gridView.layer.mask = textLayer
            
            view.addSubview(gridView)
        }
        
        // Add function
        do {
            let functionView = UIView()
            functionView.frame = view.frame
            functionView.backgroundColor = .clear
            
            
            let numberOfSteps = max(xAxis.distance, yAxis.distance) * 100
            let step = abs(xAxis.max - xAxis.min) / numberOfSteps //1000000
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
    return 5 * cos(x)
}

var graph = Graph(of: f)
graph.maxSize = CGSize.square(sideLength: 1000)
graph.line.width = 3
graph.xAxis.range = -30...30
graph.yAxis.range = -20...20
graph.applyStyle(.dark)
graph

