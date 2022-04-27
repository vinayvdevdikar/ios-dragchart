//
//  ViewController.swift
//  VDChartApp
//
//  Created by Vinay Devdikar on 22/04/22.
//

import UIKit

class ViewController: UIViewController {
    
    /// These valuse can be configure as per need of user.
    /// These values ares used to create canvas/ drawing area on screen.
    private let kTopMargin = 100.0
    private let kBottomMargin = 100.0
    private let kLeftMargin = 50.0
    private let kRightMargin = 50.0
    
    private let xAxis: [CGFloat] = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    private let yAxis: [CGFloat] = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    
    private var allXValues: [CGFloat] = []
    private var allYValues: [CGFloat] = []
    private var allXCoordinate: [CGFloat] = []
    private var allYCoordinate: [CGFloat] = []
    
    private var labelXCoordinate: UILabel?
    private var labelYCoordinate: UILabel?
    
    private lazy var roundedButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.backgroundColor = .red
        return button
    }()
    
    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        addXYLabelAtBottom()
        initializePloatingPoint(with: 0.0, startYValue: 0.0)
        drawXAxisOnScreen()
        drawYAxisOnScreen()
        drawInitalPointOnScreen(with: 5.5, yValue: 3.6)
    }
    
    deinit {
        allXValues = []
        allYValues = []
        allXCoordinate = []
        allYCoordinate = []
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let min  = min(roundedButton.frame.size.width, roundedButton.frame.size.height)
        roundedButton.layer.cornerRadius = min / 2
    }
    
    // MARK: - Drawing methods
    
    private func drawXAxisOnScreen() {
        
        /// Draw x axis on screen
        let startYValue = view.bounds.height - kTopMargin
        let endXValue = view.bounds.width - kLeftMargin + 20.0
        drawLineOnScreen(with: CGPoint(x: kLeftMargin, y: startYValue),
                         endPoint: CGPoint(x: endXValue , y: startYValue))
        
        /// Draw vertical line on graph with x axis lables.
        for element in xAxis {
            let indexOfX = allXValues.firstIndex(of: CGFloat(element))
            let endPointY = view.bounds.height - (kLeftMargin + kRightMargin)
            let startpointX = allXCoordinate[indexOfX ?? 0]
            drawLineOnScreen(with: CGPoint(x: startpointX, y: kTopMargin),
                             endPoint: CGPoint(x: startpointX, y: endPointY), color: .lightGray)
            
            /// Add number label on screen
            let frame = CGRect(x: startpointX, y: endPointY + 10.0, width: 25.0, height: 20.0)
            let label = createLabel(with: frame, text: String(format: "%.2f", element))
            label.center = CGPoint(x: startpointX, y: endPointY + 10.0)
            view.addSubview(label)
        }
    }

    private func drawYAxisOnScreen() {
        
        /// Draw y axis on screen
        let startYValue = view.bounds.height - kTopMargin
        drawLineOnScreen(with: CGPoint(x: kLeftMargin, y: startYValue),
                         endPoint: CGPoint(x: kLeftMargin, y: kTopMargin - 20.0))
        
        /// Draw horizontal line on graph with y axis lables.
        for element in yAxis {
            let indexOfY = allYValues.firstIndex(of: CGFloat(element))
            let endPointX = view.bounds.width - kLeftMargin
            let yValue = allYCoordinate[indexOfY ?? 0]
            drawLineOnScreen(with: CGPoint(x: kLeftMargin, y: yValue),
                             endPoint: CGPoint(x: endPointX, y: yValue), color: .lightGray)
            
            /// Add number label on screen
            let frame = CGRect(x: 30, y: yValue, width: 30, height: 20.0)
            let label = createLabel(with: frame, text: String(format: "%.2f", element),
                                    alignment: .center)
            label.center = CGPoint(x: 30, y: yValue)
            view.addSubview(label)
        }
    }
    
    func drawInitalPointOnScreen(with xValue: CGFloat, yValue: CGFloat) {
        guard let indexOfY = allYValues.firstIndex(of: yValue),
              let indexOfX = allXValues.firstIndex(of: xValue) else { return }
        let centerPoint = CGPoint(x: allXCoordinate[indexOfX], y: allYCoordinate[indexOfY])
        
        /// Draw diagonal line for inital point to ploatted point
        let endPoint = CGPoint(x: kLeftMargin, y: view.bounds.height - kBottomMargin)
        drawLineOnScreen(with: centerPoint, endPoint: endPoint, color: .gray)
        
        /// rounded button taking center frame.
        roundedButton.frame = CGRect(x: centerPoint.x, y: centerPoint.y, width: 10.0, height: 10.0)
        roundedButton.center = centerPoint
        view.addSubview(roundedButton)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(buttonTouches(sender:)))
        roundedButton.addGestureRecognizer(pan)
        
        labelXCoordinate?.text = "X Coordinate \(xValue)"
        labelYCoordinate?.text = "Y Coordinate \(yValue)"
    }
    
    // MARK: - Init methods
    
    func initializePloatingPoint(with startXValue: CGFloat, startYValue: CGFloat) {
            
        /// Currently we are taking base unit of 1 to 10 for X and Y axis respectively.
        /// below line of code help us to find out the actual ploating point in graph.
        for xvalue in stride (from: startXValue, to: 10.01, by: 0.01) {
            allXValues.append(xvalue)
        }
        
        for yvalue in stride (from: startYValue, to: 10.01, by: 0.01) {
            allYValues.append(yvalue)
        }
        
        /// Here we are calculating the XY cordinates
        let startPointWidth = kLeftMargin
        let endPointWidth = view.bounds.width - kRightMargin
        var incrementPoint =  endPointWidth - startPointWidth
        incrementPoint /= Double(allXValues.count)
        
        for xframe in stride (from: startPointWidth, to: endPointWidth, by: incrementPoint) {
            allXCoordinate.append(xframe)
        }
                
        let startPointHeight = kTopMargin
        let endPointHeight = view.bounds.height - kBottomMargin
        incrementPoint = endPointHeight - startPointHeight
        incrementPoint /= Double(allYValues.count)
        for yframe in stride (from: startPointHeight, to: endPointHeight, by: incrementPoint) {
            allYCoordinate.append(yframe)
        }
        
        /// To make proper ploating we need to make sure that all values same.
        let limit = allXValues.count
        allYCoordinate = allYCoordinate.reversed()
        guard limit == allYValues.count, limit == allXCoordinate.count, limit == allYCoordinate.count else {
            fatalError("Please check your start value and end value this should be in sync")
        }
    }
    
    private func addXYLabelAtBottom() {
        let tempYLabel = createLabel(with: .zero, alignment: .left)
        tempYLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tempYLabel)
        
        let tempXLabel = createLabel(with: .zero, alignment: .left)
        tempXLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tempXLabel)
        
        NSLayoutConstraint.activate([
            tempYLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0),
            tempYLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0),
            tempYLabel.heightAnchor.constraint(equalToConstant: 20.0),
            tempYLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10.0),
            tempXLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0),
            tempXLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0),
            tempXLabel.heightAnchor.constraint(equalToConstant: 20.0),
            tempXLabel.bottomAnchor.constraint(equalTo: tempYLabel.topAnchor),
        ])
        
        labelXCoordinate = tempXLabel
        labelYCoordinate = tempYLabel
    }
}

// MARK: - Helper / Reuseable Methods

extension ViewController {
    
    @objc func buttonTouches(sender: UIPanGestureRecognizer) {
        
        let location = sender.location(in: self.view)
        let canvasWidth = view.bounds.width - kRightMargin
        let canvasHeight = view.bounds.height - kBottomMargin
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
        
        ///Find out closest number from existing array.
        guard let xValue = allXCoordinate.enumerated().min( by: { abs($0.1 - location.x) < abs($1.1 - location.x) }),
              let yValue = allYCoordinate.enumerated().min( by: { abs($0.1 - location.y) < abs($1.1 - location.y) }) else {
            return
        }
        roundedButton.frame = CGRect(x: location.x, y: location.y, width: 10.0, height: 10.0)
        roundedButton.center = CGPoint(x: location.x, y: location.y)
        labelXCoordinate?.text = "X Coordinate \(allXValues[xValue.offset])"
        labelYCoordinate?.text = "Y Coordinate \(allYValues[yValue.offset])"
    }
        
    private func drawLineOnScreen(with start: CGPoint,
                                  endPoint: CGPoint,
                                  color: UIColor = .black,
                                  dashPattern: [NSNumber] = []) {
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        
        linePath.move(to: start)
        linePath.addLine(to: endPoint)
        line.path = linePath.cgPath
        line.strokeColor = color.cgColor
        line.lineWidth = 1.0
        line.lineDashPattern = dashPattern
        view.layer.addSublayer(line)
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
}
