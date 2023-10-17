//
//  HabbitViewModel.swift
//  Tracker
//
//  Created by Georgy on 01.10.2023.
//

import Foundation

final class HabbitViewModel{
    @Observable
    private(set) var completed:Bool = false
    
    private let tempStorage = TempStorage.shared
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerStore = TrackerStore()
    let mode: HabbitViewControllerMode
    
    init(mode:HabbitViewControllerMode) {
        self.mode = mode
        switch mode {
        case .create:
            tempStorage.setID(UUID())
        case .edit(let tracker, let category):
            tempStorage.set(with: tracker, and: category)
        }
    }
    
    func setEmoji(_ emoji:String){
        tempStorage.setEmoji(emoji)
    }
    
    func setColor(_ color:String){
        tempStorage.setColor(color)
    }
    
    func setName(_ name:String){
        tempStorage.setName(name)
    }
    
    func setSchedule(_ schedule:[Int]){
        tempStorage.setSchedule(schedule)
    }
    
    func getCategory() -> String{
        return tempStorage.getCategory() ?? ""
    }
    
    func getShedule() -> [Int]{
        return tempStorage.getShedule() ?? []
    }
    
    func getName() -> String{
        return tempStorage.getName() ?? ""
    }
    
    func getEmoji() -> String{
        return tempStorage.getEmoji() ?? ""
    }
    
    func getColor() -> String{
        return tempStorage.getColor() ?? ""
    }

    func shouldUpdateUI(){
        let trackerIsComplete = tempStorage.buildTracker() != nil
        completed = trackerIsComplete ? true : false
    }
    
    func addTracker(){
        guard let tracker = tempStorage.buildTracker() else { return }
        guard let title = tempStorage.getCategory() else { return }
        
        switch mode{
        case .create:
            trackerCategoryStore.addTracker(tracker, toCategoryWithTitle: title)
        case .edit(_, _):
            do{
                let object = try trackerStore.getObject(by: tracker.id)
                guard let object = object else{ return }
                try trackerStore.updateTracker(object, with: tracker)
            } catch{
                print(error)
            }
        }
    }
}
