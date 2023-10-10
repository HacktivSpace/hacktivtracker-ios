//
//  InsightsViewController.swift
//  TimeTrack
//
//  Created by Jigmet stanzin Dadul on 14/08/23.
//

import UIKit
import DGCharts
import CoreData

class InsightsViewController: UIViewController {
    
    @IBOutlet weak var topView: BarChartView!
    @IBOutlet weak var newTimerTitle: UITextField!
    @IBOutlet weak var newNotes: UITextField!
    @IBOutlet weak var categoryPopUpButton: UIButton!
    var timers: [TimerData] = []
    var categorySelected: String = "Sports"
    
    private let dBManager = DatabaseManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setPopUpButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createChart()
    }
    
    @IBAction func addButtonClicked(_ sender: UIButton) {
        guard let title = newTimerTitle.text, !title.isEmpty else {
            openAlert(message: "Enter title")
            return
        }
        guard let notes = newNotes.text, !notes.isEmpty else {
            openAlert(message: "Enter Notes")
            return
        }
        //also add for the category field
        let dBModel = DatabaseModel(timerTitle: title, timeElapsed: 0, notes: notes, category: categorySelected, heading: "It is a heading in insightViewController")
        dBManager.saveNewTimer(dBModel)
        print("Pressed")
        newNotes.text = nil
        newTimerTitle.text = nil
    }
    
    func openAlert(message: String){
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let okay = UIAlertAction(title: "Okay", style: .default)
        alertController.addAction(okay)
        present(alertController, animated: true)
    }
    
    
    
    private func createChart() {
        
        //set barchart
        let barData = getGraphData()
        topView.layer.cornerRadius = 10
        let barChart = BarChartView()
        barChart.animate(yAxisDuration: 1.0)
        barChart.drawBordersEnabled = true
        barChart.drawGridBackgroundEnabled = true
        barChart.gridBackgroundColor = UIColor(hex:  0x333739)
        
        // supplyData
        var entries = [BarChartDataEntry]()
        
        let stringLabels = ["Study","Sports", "Work","Mental" ]
        
        for (index, _) in stringLabels.enumerated() {
            entries.append(BarChartDataEntry(x: Double(index), y: barData[index+1]))
        }
        
        let set = BarChartDataSet(entries: entries, label: "Categories")
        set.valueFont = UIFont.systemFont(ofSize: 12)
        set.valueTextColor = UIColor.black
        let data = BarChartData(dataSet: set)
        data.barWidth = Double(0.5)
        set.colors = ChartColorTemplates.pastel()
        barChart.data = data
        let xAxis = barChart.xAxis
        xAxis.valueFormatter = IndexAxisValueFormatter(values: stringLabels)
        xAxis.labelCount = stringLabels.count
        xAxis.labelPosition = .bottomInside
        
        
        
        topView.addSubview(barChart)
        // Use Auto Layout constraints to adjust width and height
        barChart.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            barChart.leadingAnchor.constraint(equalTo: topView.leadingAnchor),
            barChart.trailingAnchor.constraint(equalTo: topView.trailingAnchor),
            barChart.topAnchor.constraint(equalTo: topView.topAnchor),
            barChart.bottomAnchor.constraint(equalTo: topView.bottomAnchor)
        ])
        
    }
    
    func getGraphData()->[Double]{
        timers = dBManager.fetchTimers()
        let size = 5 // Specify the size you want
        var sum = Array(repeating: 0.0, count: size)
        for timer in timers {
            sum[0] = sum[0] + timer.timeElapsed
            print(timer.category!)
            if timer.category == "Study" {
                //print("study ", timer.timeElapsed)
                sum[1] = timer.timeElapsed
            }else if timer.category == "Sports"{
                sum[2] = timer.timeElapsed
            }else if timer.category == "Work" {
                sum[3] = timer.timeElapsed
            }else{
                sum[4] = timer.timeElapsed
            }
        }
        for i in 1..<5 {
            sum[i] = sum[i]/sum[0]
        }
        
        
        print(sum)
        return sum
    }
    func setPopUpButton() {
        let selectedOption = { (action: UIAction) in
            print(action.title)
            self.categorySelected = action.title
        }
        
        let menuActions: [UIAction] = [
            UIAction(title: "Study", handler: selectedOption),
            UIAction(title: "Sports", handler: selectedOption),
            UIAction(title: "Work", handler: selectedOption),
            UIAction(title: "Mental", handler: selectedOption)
        ]
        
        let menu = UIMenu(title: "", children: menuActions)
        categoryPopUpButton.menu = menu
    }
}


extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >> 8) & 0xFF) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: alpha
        )
    }
}



