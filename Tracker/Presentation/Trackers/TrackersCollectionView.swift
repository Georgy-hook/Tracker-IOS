//
//  TrackersCollectionView.swift
//  Tracker
//
//  Created by Georgy on 27.08.2023.
//

import UIKit
final class TrackersCollectionView: UICollectionView {
    
    // MARK: - Variables
    private let params = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)
    weak var delegateVC: TrackersViewControllerProtocol?
    
    private var cells:[TrackerCategory] = []
    private var completedID: Set<UUID> = []
    // MARK: - Initiliazation
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        super.init(frame: .zero, collectionViewLayout: layout)
        
        backgroundColor = .clear
        delegate = self
        dataSource = self
        
        register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: TrackersCollectionViewCell.reuseId)
        register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        translatesAutoresizingMaskIntoConstraints = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersCollectionView:UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.reuseId, for: indexPath) as! TrackersCollectionViewCell
        cell.set(with: cells[indexPath.section].trackers[indexPath.item])
        
        cell.delegateVC = delegateVC
        if completedID.contains(cells[indexPath.section].trackers[indexPath.item].id) {
            cell.setCompletedTracker()
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension TrackersCollectionView: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! SupplementaryView
        
        view.titleLabel.text = cells[indexPath.section].title
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return contextMenuConfiguration(for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = cellForItem(at: indexPath) as? TrackersCollectionViewCell
        else {
            print("nil")
            return nil}
        
        return cell.getPreview()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersCollectionView:UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let indexPath = IndexPath(item: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: params.leftInset, bottom: 16, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 6
    }
}

extension TrackersCollectionView{
    func set(cells: [TrackerCategory]) {
        self.cells = cells
        setPinnedTrackersIfNeeded()
        self.reloadData()
    }
    
    func setPinnedTrackersIfNeeded(){
        var hasPinnedTrackers = false
        var pinnedTrackers:[Tracker] = []
        cells.forEach{
            $0.trackers.forEach{
                if $0.isPinned {
                    hasPinnedTrackers = true
                    pinnedTrackers.append($0)
                }
            }
        }
        
        if hasPinnedTrackers {
            let pinnedCategory = TrackerCategory(title: "Закрепленные", trackers: pinnedTrackers)
            cells.insert(pinnedCategory, at: 0)
        }
    }
    
    func setCompletedTrackers(with completedID:Set<UUID>){
        self.completedID = completedID
        reloadData()
    }
    
    func contextMenuConfiguration(for indexPath: IndexPath) -> UIContextMenuConfiguration {
        let pinTitle = cells[indexPath.section].trackers[indexPath.item].isPinned ?
        NSLocalizedString("Unpin", comment: "") : NSLocalizedString("Pin", comment: "")
        
        let pinAction = UIAction(title: pinTitle) { [weak self] action in
            guard let self = self else { return }
            let tracker = self.cells[indexPath.section].trackers[indexPath.item]
            
            self.delegateVC?.pinTracker(tracker)
        }
        
        let editAction = UIAction(title: NSLocalizedString("Edit", comment: "")) { [weak self] action in
            guard let self = self else { return }
            let tracker = self.cells[indexPath.section].trackers[indexPath.item]
            let category = cells[indexPath.section].title
            self.delegateVC?.editTracker(with: tracker, and: category)
        }
        
        let deleteAction = UIAction(title: NSLocalizedString("Delete", comment: ""), attributes: .destructive) { [weak self] action in
            guard let self = self else { return }
            let tracker = self.cells[indexPath.section].trackers[indexPath.item]
            
            self.delegateVC?.deleteTracker(tracker)
        }
        
        return UIContextMenuConfiguration(identifier: NSIndexPath(item: indexPath.item, section: indexPath.section), previewProvider: nil, actionProvider: { _ in
            UIMenu(title: "", children: [pinAction,editAction, deleteAction])
        })
    }
}
