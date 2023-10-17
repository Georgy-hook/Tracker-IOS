//
//  TrackersViewModel.swift
//  Tracker
//
//  Created by Georgy on 02.10.2023.
//

import Foundation

enum PlaceholderState{
    case noData
    case notFound
    case hide
}
final class TrackersViewModel{
    @Observable
    private(set) var trackers:[TrackerCategory] = []
    
    @Observable
    private(set) var currentState: PlaceholderState = .noData
    
    @Observable
    private(set) var currentDate: Date = Date()
    
    @Observable
    private(set) var completedID: Set<UUID> = []
    
    @Observable
    private(set) var currentFilter: TrackerFilter = .all
    
    private let trackerStore = TrackerStore()
    private let dateFormatter = AppDateFormatter.shared
    private let trackerRecordStore = TrackerRecordStore()
    private let tempStorage = TempStorage.shared
    private let analyticsService = AnalyticsService()
    
    init() {
        trackerStore.delegate = self
    }
    
    func configure(){
        self.trackers = trackerStore.trackers
        self.currentState = trackerStore.isEmpty() ? .noData:.hide
        self.currentDate = Date()
        self.completedID = trackerRecordStore.getCompletedID(with: currentDate)
    }
    
    func searchRelevantTrackers(with searchText: String){
        let currentDay = dateFormatter.dayOfWeekInt(for: currentDate)
        do{
            try trackerStore.searchTrackers(with: searchText, forDay: currentDay)
            self.trackers = trackerStore.trackers
            currentFilter = .all
            currentState = trackerStore.isEmpty() ? .notFound:.hide
        }catch{
            print("Error searching for trackers: \(error)")
        }
    }
    
    func filterRelevantTrackers(for currentDate: Date){
        let currentDay = dateFormatter.dayOfWeekInt(for: currentDate)
        do {
            try trackerStore.fetchRelevantTrackers(forDay: currentDay)
            self.trackers = trackerStore.trackers
            
            currentState = trackerStore.isEmpty() ? .noData:.hide
        }
        catch {
           print(error)
        }
    }
    
    func setCurrentDate(with date:Date){
        self.currentDate = date
        currentFilter = .all
        completedID = trackerRecordStore.getCompletedID(with: currentDate)
    }
    
    func resetTempTracker(){
        tempStorage.resetTempTracker()
    }

    func addCompletedTracker(_ tracker: Tracker) {
        let newRecord = TrackerRecord(recordID: tracker.id, date: currentDate)
        do{
            analyticsService.report(event: .click, screen: .main, item: .track)
            try trackerRecordStore.addNewRecord(newRecord)
        } catch{
            print("Error with completedTrackers: \(error)")
        }
    }
    
    func removeCompletedTracker(_ tracker: Tracker) {
        do {
            try trackerRecordStore.removeRecord(for: tracker.id, with: currentDate)
        } catch {
            print("No delete: \(error)")
        }
    }
    
    func countRecords(forUUID uuid: UUID) -> Int{
        return trackerRecordStore.countRecords(forUUID: uuid)
    }
    
    func editTracker() {
        analyticsService.report(event: .click, screen: .main, item: .edit)
    }
    
    func deleteTracker(_ tracker: Tracker) {
       
        do{
            try trackerStore.deleteObject(at: tracker.id)
            analyticsService.report(event: .click, screen: .main, item: .delete)
            
        } catch{
            print(error)
        }
    }
    
    func pinTracker(_ tracker: Tracker) {
        let pinnedTracker = Tracker(id: tracker.id,
                                    name: tracker.name,
                                    color: tracker.color,
                                    emoji: tracker.emoji,
                                    schedule: tracker.schedule,
                                    isPinned: !tracker.isPinned)
        do{
            guard let object = try trackerStore.getObject(by: tracker.id) else{ return }
            
            try trackerStore.updateTracker(object, with: pinnedTracker)
            
            filterRelevantTrackers(for: currentDate)
        } catch{
            print(error)
        }
    }
    
    func createTracker(){
        analyticsService.report(event: .click, screen: .main, item: .addTrack)
    }
    
    func viewDidLoad(){
        analyticsService.report(event: .open, screen: .main, item: nil)
    }
    
    func viewWillDisappear(){
        analyticsService.report(event: .close, screen: .main, item: nil)
    }
    
    func didFilterButtonTapped(){
        analyticsService.report(event: .click, screen: .main, item: .filter)
    }
    
    func setFilter(with filter:TrackerFilter){
        currentFilter = filter
    }
    
    func filterTrackersWithCurrentFilter(){
        let currentDay = dateFormatter.dayOfWeekInt(for: currentDate)
        switch currentFilter {
        case .all:
            do {
                try trackerStore.fetchRelevantTrackers(forDay: currentDay)
            } catch {
                print(error)
            }
        case .today:
            currentDate = Date()
            self.completedID = trackerRecordStore.getCompletedID(with: currentDate)
        case .completed:
            do {
                self.completedID = trackerRecordStore.getCompletedID(with: currentDate)
                try trackerStore.getCompletedTrackers(forDay: currentDay, completedID: completedID)
                self.trackers = trackerStore.trackers
            } catch {
                print(error)
            }
        case .incomplete:
            do {
                self.completedID = trackerRecordStore.getCompletedID(with: currentDate)
                try trackerStore.getIncompleteTrackers(forDay: currentDay, completedID: completedID)
                self.trackers = trackerStore.trackers
            } catch {
                print(error)
            }
        }
    }
}

extension TrackersViewModel:TrackerStoreDelegate{
    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate) {
        self.trackers = store.trackers
        completedID = trackerRecordStore.getCompletedID(with: currentDate)
    }
}
