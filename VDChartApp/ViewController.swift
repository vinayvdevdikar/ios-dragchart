//
//  ViewController.swift
//  VDChartApp
//
//  Created by Vinay Devdikar on 22/04/22.
//

import UIKit

class ViewController: UIViewController {
    
    private let xAxis: [CGFloat] = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    private let yAxis: [CGFloat] = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    
    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
     
        let chartView = VDChartView(with: xAxis, with: yAxis)
       // chartView.initAllData()
        chartView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chartView)
        NSLayoutConstraint.activate([
            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chartView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            chartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])
    }
}
