//
//  DatabaseManager.swift
//  HactivTracker
//
//  Created by Jigmet stanzin Dadul on 26/08/23.
//

import CoreData
import UIKit


class DatabaseManager{
    private var context: NSManagedObjectContext{
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    
    func saveNewTimer(_ newTimer: DatabaseModel){
        let timerData = TimerData(context: context)
        timerData.timerTitle = newTimer.timerTitle
        timerData.notes = newTimer.notes
        timerData.heading = newTimer.heading
        timerData.category = newTimer.category
        timerData.timeElapsed = newTimer.timeElapsed
        
        do{
            try context.save()
        }catch{
            print("User saving error:", error)
        }
        
    }
    
    func fetchTimers()-> [TimerData]{
        var timers: [TimerData] = []
        
        do{
            try timers = context.fetch(TimerData.fetchRequest())
        }catch{
            print("Fetch User errors", error)
        }
        return timers
    }
    
    func deleteTimer(timer: TimerData) {
        context.delete(timer)
        
        do {
            try context.save()
        } catch {
            print("Delete timer error:", error)
        }
    }
    
    func updateTimer(timer: TimerData, with newTimer: DatabaseModel) {
        timer.timerTitle = newTimer.timerTitle
        timer.notes = newTimer.notes
        timer.heading = newTimer.heading
        timer.category = newTimer.category
        timer.timeElapsed = newTimer.timeElapsed
        
        do {
            try context.save()
        } catch {
            print("Update timer error:", error)
        }
    }
    
}
