//
//  VDCharView.swift
//  VDChartApp
//
//  Created by Vinay Devdikar on 17/06/22.
//

import UIKit
final class VDChartView: UIView {
    
    /// These valuse can be configure as per need of user.
    /// These values ares used to create canvas/ drawing area on screen.
    private let kTopMargin = 100.0
    private let kBottomMargin = 100.0
    private let kLeftMargin = 50.0
    private let kRightMargin = 50.0
    private let kMargin = 20.0

    private let yAxisLabelSize = CGSize(width: 30.0, height: 20.0)
    private let xAxisLabelSize = CGSize(width: 25.0, height: 20.0)
    private let kRedCircleSize = CGSize(width: 10.0, height: 10.0)
    private let floatDisplayFormat: String = "%.2f"
    
    private var allXValues: [CGFloat] = []
    private var allYValues: [CGFloat] = []
    private var allXCoordinate: [CGFloat] = []
    private var allYCoordinate: [CGFloat] = []
    
    private var labelXCoordinate: UILabel?
    private var labelYCoordinate: UILabel?
    private var lineToPoint: CAShapeLayer!
    private let linePath = UIBezierPath()
    
    private let xAxis: [CGFloat]
    private let yAxis: [CGFloat]
    private let isDrawingCompleted: Bool = false
    
    private lazy var roundedButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.backgroundColor = .red
        return button
    }()
    
    init(with xAxisValues: [CGFloat], with yAxisValues: [CGFloat]) {
        self.xAxis = xAxisValues
        self.yAxis = yAxisValues
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        allXValues = []
        allYValues = []
        allXCoordinate = []
        allYCoordinate = []
        
        labelXCoordinate  = nil
        labelYCoordinate = nil
        lineToPoint  = nil
    }
    
    override func draw(_ rect: CGRect) {
        
        /// This check prevents the compiler to draw multiple graphs.
        if !isDrawingCompleted {
            initAllData()
        }
    }
    
   private func initAllData() {
        //Initially draw X and Y lines.
        addXYLabelAtBottom()
        
        /// This init method helps to find all possible values in a given drawing area.
        initializePloatingPoint(with: 0.0, startYValue: 0.0)
        
        /// draw X axis on screen.
        drawXAxisOnScreen()
        
        /// draw Y axis on screen.
        drawYAxisOnScreen()
        
        /// To draw different inital points on the screen please change these values.
        drawInitalPointOnScreen(with: 5.5, yValue: 3.6)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let min  = min(roundedButton.frame.size.width, roundedButton.frame.size.height)
        roundedButton.layer.cornerRadius = min / 2
    }
    
    // MARK: - Init Ploating methods
    
    func initializePloatingPoint(with startXValue: CGFloat, startYValue: CGFloat) {
            
        /// We are currently taking base units from 1 to 10 for the X and Y axes respectively.
        /// Below the line of code help us to find out the actual plotting point in the graph.
        for xvalue in stride (from: startXValue, to: 10.01, by: 0.01) {
            allXValues.append(xvalue)
        }
        
        for yvalue in stride (from: startYValue, to: 10.01, by: 0.01) {
            allYValues.append(yvalue)
        }
        
        /// we are calculating the XY coordinates.
        let startPointWidth = kLeftMargin
        let endPointWidth = bounds.width - kRightMargin
        var incrementPoint =  endPointWidth - startPointWidth
        incrementPoint /= Double(allXValues.count)
        
        for xframe in stride (from: startPointWidth, to: endPointWidth, by: incrementPoint) {
            allXCoordinate.append(xframe)
        }
                
        let startPointHeight = kTopMargin
        let endPointHeight = bounds.height - kBottomMargin
        incrementPoint = endPointHeight - startPointHeight
        incrementPoint /= Double(allYValues.count)
        for yframe in stride (from: startPointHeight, to: endPointHeight, by: incrementPoint) {
            allYCoordinate.append(yframe)
        }
        
        /// To make proper plotting we need to make sure that all values same.
        let limit = allXValues.count
        allYCoordinate = allYCoordinate.reversed()
        guard limit == allYValues.count, limit == allXCoordinate.count, limit == allYCoordinate.count else {
            fatalError("Please check your start value and end value this needs to be in sync")
        }
    }
    
    
}

// MARK: - Drawing methods

extension VDChartView {

    private func addXYLabelAtBottom() {
        let tempYLabel = createLabel(with: .zero, alignment: .left)
        tempYLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tempYLabel)
        
        let tempXLabel = createLabel(with: .zero, alignment: .left)
        tempXLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tempXLabel)
        
        NSLayoutConstraint.activate([
            tempYLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: kMargin),
            tempYLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -kMargin),
            tempYLabel.heightAnchor.constraint(equalToConstant: kMargin),
            tempYLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10.0),
            tempXLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: kMargin),
            tempXLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -kMargin),
            tempXLabel.heightAnchor.constraint(equalToConstant: kMargin),
            tempXLabel.bottomAnchor.constraint(equalTo: tempYLabel.topAnchor),
        ])
        
        labelXCoordinate = tempXLabel
        labelYCoordinate = tempYLabel
    }
    

    private func drawXAxisOnScreen() {
        
        /// Draw x axis on screen
        let startYValue = bounds.height - kTopMargin
        let endXValue = bounds.width - kLeftMargin + 20.0
        let xAxisLine = drawLineOnScreen(with: CGPoint(x: kLeftMargin, y: startYValue),
                         endPoint: CGPoint(x: endXValue , y: startYValue))
        layer.addSublayer(xAxisLine)
        
        /// Draw a vertical line on a graph with x-axis labels.
        for element in xAxis {
            let indexOfX = allXValues.firstIndex(of: CGFloat(element))
            let endPointY = bounds.height - (kLeftMargin + kRightMargin)
            let startpointX = allXCoordinate[indexOfX ?? 0]
            let parallelLine = drawLineOnScreen(with: CGPoint(x: startpointX, y: kTopMargin),
                             endPoint: CGPoint(x: startpointX, y: endPointY), color: .lightGray)
            layer.addSublayer(parallelLine)
            
            /// Added extra padding in endpoint Y value to increase the line to 10px
            let endPointYWithPadding = endPointY + 10.0
            
            /// Add numbers label on the screen.
            let frame = CGRect(x: startpointX, y: endPointYWithPadding, width: xAxisLabelSize.width, height: xAxisLabelSize.height)
            let label = createLabel(with: frame, text: String(format: floatDisplayFormat, element))
            label.center = CGPoint(x: startpointX, y: endPointYWithPadding)
            addSubview(label)
        }
    }

    private func drawYAxisOnScreen() {
        
        /// Draw y axis on the screen
        let startYValue = bounds.height - kTopMargin
        let endPointYValue = kTopMargin - 20.0 // this 20 px added to move increase the line.
        let yAxisLine = drawLineOnScreen(with: CGPoint(x: kLeftMargin, y: startYValue),
                         endPoint: CGPoint(x: kLeftMargin, y: endPointYValue))
        layer.addSublayer(yAxisLine)
        
        /// Draw a horizontal line on a graph with y-axis labels.
        for element in yAxis {
            let indexOfY = allYValues.firstIndex(of: CGFloat(element))
            let endPointX = bounds.width - kLeftMargin
            let yValue = allYCoordinate[indexOfY ?? 0]
            let parallelLine = drawLineOnScreen(with: CGPoint(x: kLeftMargin, y: yValue),
                             endPoint: CGPoint(x: endPointX, y: yValue), color: .lightGray)
            layer.addSublayer(parallelLine)
            
            /// Add number labels on the screen.
            let frame = CGRect(x: kMargin, y: yValue, width: xAxisLabelSize.width, height: xAxisLabelSize.height)
            let label = createLabel(with: frame, text: String(format: floatDisplayFormat, element),
                                    alignment: .right)
            label.center = CGPoint(x: kMargin, y: yValue)
            addSubview(label)
        }
    }
    
    func drawInitalPointOnScreen(with xValue: CGFloat, yValue: CGFloat) {
        guard let indexOfY = allYValues.firstIndex(of: yValue),
              let indexOfX = allXValues.firstIndex(of: xValue) else { return }
        let centerPoint = CGPoint(x: allXCoordinate[indexOfX], y: allYCoordinate[indexOfY])
        
        /// Draw a diagonal line from an initial point to a given point.
        let endPoint = CGPoint(x: kLeftMargin, y: bounds.height - kBottomMargin)
        lineToPoint = drawLineOnScreen(with: centerPoint, endPoint: endPoint, color: .gray)
        layer.addSublayer(lineToPoint!)
        
        /// Rounded button taking centre frame.
        roundedButton.frame = CGRect(x: centerPoint.x,
                                     y: centerPoint.y,
                                     width: kRedCircleSize.width,
                                     height: kRedCircleSize.height)
        roundedButton.center = centerPoint
        addSubview(roundedButton)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(buttonTouches(sender:)))
        roundedButton.addGestureRecognizer(pan)
        
        labelXCoordinate?.text = "X Coordinate \(xValue)"
        labelYCoordinate?.text = "Y Coordinate \(yValue)"
    }
}


// MARK: - Helper / Reuseable Methods

extension VDChartView {
    
    @objc func buttonTouches(sender: UIPanGestureRecognizer) {
        
        let location = sender.location(in: self)
        let canvasWidth = bounds.width - kRightMargin
        let canvasHeight = bounds.height - kBottomMargin
        print(location.x , location.y)
        guard sender.state != .ended,
                sender.state != .failed,
                sender.state != .cancelled,
                location.x > kLeftMargin,
                location.x < canvasWidth,
                location.y > kTopMargin,
                location.y < canvasHeight else {
            return
        }
        
        /// Find out the closest number from the existing array.
        guard let xValue = allXCoordinate.enumerated().min( by: { abs($0.1 - location.x) < abs($1.1 - location.x) }),
              let yValue = allYCoordinate.enumerated().min( by: { abs($0.1 - location.y) < abs($1.1 - location.y) }) else {
            return
        }
        roundedButton.frame.origin = CGPoint(x: location.x, y: location.y)
        roundedButton.center = CGPoint(x: location.x, y: location.y)
        labelXCoordinate?.text = String(format: "X Coordinate %.2f", allXValues[xValue.offset])
        labelYCoordinate?.text = String(format: "X Coordinate %.2f", allYValues[yValue.offset])
        
        /// Update diagonal line for initial point to plotted point.
        let endPoint = CGPoint(x: kLeftMargin, y: bounds.height - kBottomMargin)
        updateExistingLine(with: lineToPoint, start: CGPoint(x: location.x, y: location.y), endPoint: endPoint)
    }
        
    private func drawLineOnScreen(with start: CGPoint,
                                  endPoint: CGPoint,
                                  color: UIColor = .black,
                                  dashPattern: [NSNumber] = []) -> CAShapeLayer {
        let line = CAShapeLayer()
        linePath.move(to: start)
        linePath.addLine(to: endPoint)
        line.path = linePath.cgPath
        line.strokeColor = color.cgColor
        line.lineWidth = 1.0
        line.lineDashPattern = dashPattern
        return line
    }

    private func createLabel(with frame: CGRect,
                             text: String = "", alignment: NSTextAlignment = .right) -> UILabel {
        let label = UILabel(frame: frame)
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 8.0)
        label.textColor = .black
        label.textAlignment = alignment
        label.text = text
        return label
    }
    
    private func updateExistingLine(with line: CAShapeLayer,
                                    start: CGPoint,
                                    endPoint: CGPoint) {
        let linePath = UIBezierPath()
        linePath.move(to: start)
        linePath.addLine(to: endPoint)
        line.path = linePath.cgPath
    }
}
