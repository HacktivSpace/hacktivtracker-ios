//
//  HomeViewController.swift
//  TimeTrack
//
//  Created by Jigmet stanzin Dadul on 06/08/23.
//

import UIKit
import Combine
import CoreData

class HomeViewController: UIViewController {
    
    
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerTitleLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var aboutTimeView: UIView!
    @IBOutlet weak var notesText: UITextView!
    var isTimerRunning = false
    var currentTimerIndex: Int = 0;
    var timers: [TimerData] = []
    var timerViewModel = TimerViewModel()
    let dBManager = DatabaseManager()
    
    var cancellable: AnyCancellable?
    private var cancellables: Set<AnyCancellable> = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        notesText.delegate = self
        tableView.delegate = self
        //give radius only to the bottom
        topView.layer.cornerRadius = 15
        topView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        timerView.layer.cornerRadius = 20
        aboutTimeView.layer.cornerRadius = 10
        // Update the label text using the formattedElapsedTime function
        timerViewModel.$elapsedTime.sink { [weak self] elapsedTime in
            self?.timerLabel.text = TimeFormatter.formattedElapsedTime(elapsedTime)
            self?.updateTimerVal(elapsedTime: elapsedTime)
        }.store(in: &cancellables)
        
        tableView.register(UINib(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: "HomeTableViewCell")
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timers = dBManager.fetchTimers()
        //Updating the Timer when the screen will load for the first timer
        if !timers.isEmpty {
            let timer = timers[0]
            timerTitleLabel.text = timer.timerTitle
            category.text = timer.category
            notesText.text = timer.notes
            timerViewModel.elapsedTime = timer.timeElapsed
        }
        
        tableView.reloadData()
    }
   
    func updateTimerVal(elapsedTime: Double){
        if !isTimerRunning {
            print("error 1212")
            return // Only update Core Data if timer is stopped
        }
        
        guard currentTimerIndex < timers.count else {
            print("error 4545")
            return // Ensure that the index is valid
        }
        let timer = timers[currentTimerIndex]
        let newdBModel = DatabaseModel(timerTitle: timer.timerTitle!, timeElapsed: elapsedTime, notes: timer.notes!, category: timer.category!, heading: timer.heading!)
        dBManager.updateTimer(timer: timer, with: newdBModel) // Save the changes to Core Data
        
        print("Storing time")
    }
   
    
    @objc func loadList(notification: NSNotification){
        //load data here
        self.tableView.reloadData()
    }
    
    
    @IBAction func startStopButtonClicked(_ sender: UIButton) {
        timerViewModel.startStopTimer()
        isTimerRunning = !isTimerRunning
        //Update the button text
        if (timerViewModel.scheduledTimer != nil) {
            sender.setTitle("Stop", for: .normal)
        }else{
            sender.setTitle("Start", for: .normal)
        }
        
    }
    
    @IBAction func resetButtonClicked(_ sender: UIButton){
        timerViewModel.restartTimer()
        startStopButton.titleLabel?.text = "Start "
    }
}


extension HomeViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell") as? HomeTableViewCell else{
            
            return UITableViewCell()
        }
        let timer = timers[indexPath.row]
        cell.timerTitle.text = timer.timerTitle
        cell.timerNotes.text = timer.notes
        cell.timer.text = TimeFormatter.formattedElapsedTime(timer.timeElapsed)
        cell.timerCategoryButton.titleLabel?.text = timer.category
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        timerViewModel.stopTimer()
        startStopButton.titleLabel?.text = "Start"
        currentTimerIndex = indexPath.row
        let timer = timers[indexPath.row]
        timerTitleLabel.text = timer.timerTitle
        category.text = timer.category
        notesText.text = timer.notes
        timerViewModel.elapsedTime = timer.timeElapsed
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, handler in
            //self?.tableView.deleteRows(at: [indexPath], with: .automatic)
            // Update data source
            let deletedTimer = self?.timers.remove(at: indexPath.row)
            self?.dBManager.deleteTimer(timer: deletedTimer!) // Delete from Core Data
            
            self?.tableView.beginUpdates()
            self?.tableView.deleteRows(at: [indexPath], with: .automatic)
            self?.tableView.endUpdates()
        }
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        return config
    }
    
}

extension HomeViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        
        let timer = timers[currentTimerIndex]
        let newdBModel = DatabaseModel(timerTitle: timer.timerTitle!, timeElapsed: timer.timeElapsed, notes: textView.text, category: timer.category!, heading: timer.heading!)
        dBManager.updateTimer(timer: timers[currentTimerIndex], with: newdBModel) // Save the changes to Core Data
        
        print("Editing done. Updated notes : \(newdBModel.notes)")
    }
}


