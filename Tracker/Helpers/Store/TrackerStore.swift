//
//  TrackerStore.swift
//  Tracker
//
//  Created by Georgy on 10.09.2023.
//

import CoreData
import UIKit

enum TrackerStoreError: Error{
    case decodingErrorInvalidID
    case decodingErrorInvalidName
    case decodingErrorInvalidColor
    case decodingErrorInvalidEmoji
    case decodingErrorInvalidCategory
    case deletingError
}

struct TrackerStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

protocol TrackerStoreDelegate: AnyObject{
    func store(
        _ store: TrackerStore,
        didUpdate update: TrackerStoreUpdate
    )
}

final class TrackerStore: NSObject{
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    weak var delegate: TrackerStoreDelegate?
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerStoreUpdate.Move>?
    
    var trackers: [TrackerCategory] {
        guard let objects = self.fetchedResultsController?.fetchedObjects,
              let trackers = try? makeCategory(from: objects)
        else { return [] }
        return trackers
    }
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do { try self.init(context: context) }
        catch{
            fatalError("Init error")
        }
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        try makeFetchRequest(with: nil)
    }
    
    
    
    func addNewTracker(_ tracker:Tracker) throws -> TrackerCoreData{
        let trackerCoreData = TrackerCoreData(context: context)
        try updateTracker(trackerCoreData, with: tracker)
        return trackerCoreData
    }
    
    func updateTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) throws {
        trackerCoreData.uuid = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.isPinned = tracker.isPinned
        
        let newSchedules = tracker.schedule.map { dayOfWeek in
            let schedule = ScheduleCoreData(context: context)
            schedule.dayOfWeek = Int32(dayOfWeek)
            return schedule
        }
        trackerCoreData.schedule = NSSet(array: newSchedules)
        try context.save()
        try fetchedResultsController?.performFetch()
    }
    
    
    func makeTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker{
        guard let id = trackerCoreData.uuid else {
            throw TrackerStoreError.decodingErrorInvalidID
        }
        guard let name = trackerCoreData.name else {
            throw TrackerStoreError.decodingErrorInvalidName
        }
        guard let color = trackerCoreData.color else {
            throw TrackerStoreError.decodingErrorInvalidColor
        }
        guard let emoji = trackerCoreData.emoji else {
            throw TrackerStoreError.decodingErrorInvalidEmoji
        }
        
        let isPinned = trackerCoreData.isPinned
        
        let schedule = makeSchedule(from:trackerCoreData.schedule?.allObjects as? [ScheduleCoreData])
        
        return(Tracker(id: id,
                       name: name,
                       color: color,
                       emoji: emoji,
                       schedule: schedule,
                       isPinned: isPinned))
    }
    
    func makeSchedule(from scheduleCoreData: [ScheduleCoreData]?) -> [Int]{
        guard let scheduleCoreData = scheduleCoreData else {return []}
        return scheduleCoreData.map{Int($0.dayOfWeek)}
    }
    
    func makeCategory(from trackerCoreDataObjects: [TrackerCoreData]) throws -> [TrackerCategory] {
        var trackerCategoryDict = [String: [Tracker]]()
        
        for trackerCoreData in trackerCoreDataObjects {
            do {
                let tracker = try makeTracker(from: trackerCoreData)
                if let categoryTitle = trackerCoreData.category?.title {
                    if var trackersForCategory = trackerCategoryDict[categoryTitle] {
                        trackersForCategory.append(tracker)
                        trackerCategoryDict[categoryTitle] = trackersForCategory
                    } else {
                        trackerCategoryDict[categoryTitle] = [tracker]
                    }
                }
            } catch {
                throw TrackerStoreError.decodingErrorInvalidCategory
            }
        }
        
        let trackerCategories = trackerCategoryDict.map { (title, trackers) in
            return TrackerCategory(title: title, trackers: trackers)
        }
        return trackerCategories
    }
    
    func getTracker(by uuid: String) throws -> Tracker? {
        let predicate = NSPredicate(format: "uuid == %@", uuid as CVarArg)
        do {
            try  makeFetchRequest(with: predicate)
        } catch{
            print(error)
        }
        
        
        guard let trackerCoreData = fetchedResultsController?.fetchedObjects?.first else {
            print("Tracker not found")
            return nil
        }
        
        do {
            let tracker = try makeTracker(from: trackerCoreData)
            return tracker
        } catch {
            throw error
        }
    }
    
    func getObject(by uuid:UUID) throws -> TrackerCoreData? {
        let predicate = NSPredicate(format: "uuid == %@", uuid as CVarArg)
        do {
            try  makeFetchRequest(with: predicate)
        } catch{
            print(error)
        }
        guard let trackerCoreData = fetchedResultsController?.fetchedObjects?.first else {
            print("Tracker not found")
            return nil
        }
        
        return trackerCoreData
    }
    func isEmpty() -> Bool {
        guard let objects = self.fetchedResultsController?.fetchedObjects else {
            return true
        }
        return objects.isEmpty
    }
    
    func deleteObject(at uuid:UUID) throws{
        guard let fetchedResultsController = fetchedResultsController,
              let objects = fetchedResultsController.fetchedObjects else {
            return
        }
        
        if let objectToDelete = objects.first(where: {
            $0.uuid == uuid
        }){
            context.delete(objectToDelete)
            try context.save()
            try fetchedResultsController.performFetch()
        } else {
            throw TrackerStoreError.deletingError
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore:NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerStoreUpdate.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: TrackerStoreUpdate(
                insertedIndexes: insertedIndexes!,
                deletedIndexes: deletedIndexes!,
                updatedIndexes: updatedIndexes!,
                movedIndexes: movedIndexes!
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
        movedIndexes = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError() }
            insertedIndexes?.insert(indexPath.item)
        case .delete:
            guard let indexPath = indexPath else { fatalError() }
            deletedIndexes?.insert(indexPath.item)
        case .update:
            guard let indexPath = indexPath else { fatalError() }
            updatedIndexes?.insert(indexPath.item)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { fatalError() }
            movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
        @unknown default:
            fatalError()
        }
    }
}

// MARK: - Search methods
extension TrackerStore{
    func fetchRelevantTrackers(forDay day: Int) throws {
        let predicate = NSPredicate(format: " %K CONTAINS %d", #keyPath(TrackerCoreData.schedule.dayOfWeek), day)
        try makeFetchRequest(with: predicate)
    }
    
    
    func searchTrackers(with searchText: String, forDay day: Int) throws  {
        guard !searchText.isEmpty else {
            try fetchRelevantTrackers(forDay: day)
            return
        }
        
        let predicate = NSPredicate(format: "%K CONTAINS[c] %@ AND %K CONTAINS %d ",
                                    #keyPath(TrackerCoreData.name), searchText,
                                    #keyPath(TrackerCoreData.schedule.dayOfWeek), day)
        try makeFetchRequest(with: predicate)
    }
    
    func getCompletedTrackers(forDay day: Int, completedID: Set<UUID>) throws {
        let completedIDArray = Array(completedID)
        let predicate = NSPredicate(format: "%K CONTAINS %d AND %K IN %@",
                                    #keyPath(TrackerCoreData.schedule.dayOfWeek), day,
                                    #keyPath(TrackerCoreData.uuid), completedIDArray)
        try makeFetchRequest(with: predicate)
    }
    
    func getIncompleteTrackers(forDay day: Int, completedID: Set<UUID>) throws {
        let completedIDArray = Array(completedID)
        let predicate = NSPredicate(format: "%K CONTAINS %d AND NOT %K IN %@",
                                    #keyPath(TrackerCoreData.schedule.dayOfWeek), day,
                                    #keyPath(TrackerCoreData.uuid), completedIDArray)
        try makeFetchRequest(with: predicate)
    }
    
    private func makeFetchRequest(with predicate:NSPredicate?) throws{
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)
        ]
        
        if let predicate = predicate{
            fetchRequest.predicate = predicate
        }
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        
        self.fetchedResultsController = controller
        
        try controller.performFetch()
    }
}
