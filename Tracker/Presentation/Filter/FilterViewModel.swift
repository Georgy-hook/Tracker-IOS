//
//  FilterViewModel.swift
//  Tracker
//
//  Created by Georgy on 16.10.2023.
//

import Foundation

enum TrackerFilter: String, CaseIterable {
    case all = "Все трекеры"
    case today = "Трекеры на сегодня"
    case completed = "Завершенные"
    case incomplete = "Не завершенные"
}

final class FilterViewModel{
    let filters:[TrackerFilter] = TrackerFilter.allCases
    
    private var currentFilter: TrackerFilter = .all
    
    func setFilter(with filter:TrackerFilter){
        currentFilter = filter
    }
    
    func isFilterSelected(_ filter: TrackerFilter) -> Bool{
        return filter == currentFilter
    }
}
