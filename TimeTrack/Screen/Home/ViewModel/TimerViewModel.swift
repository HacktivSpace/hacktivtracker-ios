//
//  TimeCountViewModel.swift
//  TimeTrack
//
//  Created by Jigmet stanzin Dadul on 08/08/23.
//

import Foundation

class TimerViewModel: ObservableObject {
    var scheduledTimer: Timer?

    // The variable that will be observed as it changes wihting a function 
    @Published var elapsedTime: TimeInterval = 0

    //Func that handles stopping and starting the timer
    func startStopTimer() {
        //Will stop the timer
        if let timer = scheduledTimer {
            timer.invalidate()
            scheduledTimer = nil
        }else{
            scheduledTimer = Timer(timeInterval: 1, repeats: true) { [weak self] timer in
                self?.elapsedTime += timer.timeInterval
            }
            RunLoop.current.add(scheduledTimer!, forMode: .common)
        }
    }
    func stopTimer(){
        if let timer = scheduledTimer{
            timer.invalidate()
            scheduledTimer?.invalidate()
        }
    }
    func restartTimer(){
        if let timer = scheduledTimer{
            elapsedTime = 0
            timer.invalidate()
            scheduledTimer = nil
        }else{
            return
        }
        
    }
}
//Formates the seconds elapsed in minutes and hour
class TimeFormatter {
    static func formattedElapsedTime(_ elapsedTime: TimeInterval) -> String {
        let hours = Int(elapsedTime) / 3600 % 24
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d : %02d : %02d", hours, minutes, seconds)
    }
}
