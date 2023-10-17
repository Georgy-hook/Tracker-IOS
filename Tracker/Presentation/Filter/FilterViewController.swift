//
//  FilterViewController.swift
//  Tracker
//
//  Created by Georgy on 16.10.2023.
//

import UIKit

protocol FilterViewControllerProtocol:AnyObject{
    func presentTrackerVC(with filter: TrackerFilter)
    func getCountOfFilters() -> Int
    func isFilterSelected(_ filter: TrackerFilter) -> Bool
}

final class FilterViewController: UIViewController{
    // MARK: - UI Elements
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Filters", comment: "")
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let filterTableView = FilterTableView()
    
    // MARK: - Variables
    private var viewModel = FilterViewModel()
    var onFilterReceived: ((TrackerFilter) -> Void)?
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        addSubviews()
        applyConstraints()
        
    }
}

// MARK: - Layout
extension FilterViewController {
    private func configureUI() {
        view.backgroundColor = UIColor(named: "YP White")
        
        filterTableView.delegateVC = self
        filterTableView.set(with: viewModel.filters)
    }
    
    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(filterTableView)
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            filterTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            filterTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension FilterViewController: FilterViewControllerProtocol{
    func presentTrackerVC(with filter: TrackerFilter) {
        onFilterReceived?(filter)
        dismiss(animated: true)
    }
    
    func getCountOfFilters() -> Int {
        viewModel.filters.count
    }
    
    func isFilterSelected(_ filter: TrackerFilter) -> Bool {
        return viewModel.isFilterSelected(filter)
    }
    
    func setCurrentFilter(filter: TrackerFilter){
        viewModel.setFilter(with: filter)
    }
}
