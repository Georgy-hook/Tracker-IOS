//
//  FilterTableView.swift
//  Tracker
//
//  Created by Georgy on 16.10.2023.
//

import UIKit

final class FilterTableView:UITableView{
    // MARK: - Variables
    private var filters:[TrackerFilter] =  []
    
    weak var delegateVC: FilterViewControllerProtocol?
    // MARK: - Initiliazation
    init() {
        super.init(frame: .zero, style: .plain)
        translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 16
        self.backgroundColor = .clear
        self.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.tableFooterView = UIView()
        self.showsVerticalScrollIndicator = false
        self.tintColor = .clear
        delegate = self
        dataSource = self
        register(FilterCell.self, forCellReuseIdentifier: FilterCell.reuseId)
    }
    
    override func layoutSubviews() {
        hideLastSeparator()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return  CGSize(width: 0, height: filters.count * 75)
     }
}

// MARK: - UITableViewDataSource
extension FilterTableView:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegateVC?.getCountOfFilters() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.dequeueReusableCell(withIdentifier: FilterCell.reuseId) as? FilterCell
        else { return UITableViewCell() }
        let selected = delegateVC?.isFilterSelected(filters[indexPath.row]) ?? false
        cell.set(with: filters[indexPath.row].rawValue, selected: selected)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FilterTableView:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegateVC?.presentTrackerVC(with: filters[indexPath.row])
    }
}

extension FilterTableView {
    func set(with filters: [TrackerFilter]) {
        self.filters = filters
        self.reloadData()
        
        updateTableViewHeight()
    }
    
    private func hideLastSeparator(){
        let lastIndexPath = IndexPath(row: filters.count - 1, section: 0)
        if let lastCell = cellForRow(at: lastIndexPath) {
            let separatorFrame = CGRect(x: lastCell.separatorInset.left, y: lastCell.frame.maxY - 1, width: lastCell.frame.width - lastCell.separatorInset.left - lastCell.separatorInset.right, height: 1)
            let separatorView = UIView(frame: separatorFrame)
            separatorView.backgroundColor = UIColor(named: "YP White")
            addSubview(separatorView)
        }
    }
    
    func updateTableViewHeight() {
        invalidateIntrinsicContentSize()
    }
}
