//
//  TrackersCollectionViewCell.swift
//  Tracker
//
//  Created by Georgy on 27.08.2023.
//

import UIKit

class TrackersCollectionViewCell: UICollectionViewCell {
    
    static let reuseId = "TrackersCollectionViewCell"
    
    private var tracker:Tracker?
    
    private var completedDays = 0 {
        didSet {
            counterLabel.text = String.localizedStringWithFormat(NSLocalizedString("Completed days", comment: "Number of completed days"), completedDays)
        }
    }
    
    weak var delegateVC: TrackersViewControllerProtocol?{
        didSet{
            configureUI()
        }
    }
    
    private let counterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "YP Black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let checkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ButtonPlus")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.setImage(UIImage(named: "Done")?.withRenderingMode(.alwaysTemplate), for: .selected)
        button.layer.cornerRadius = 17
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        
        return view
    }()
    private let emojiTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textField.textAlignment = .center
        textField.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        textField.isUserInteractionEnabled = false
        textField.layer.cornerRadius = 12
        textField.clipsToBounds = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Pin")
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubviews()
        applyConstraints()
        checkButton.addTarget(self, action: #selector(checkButtonDidTapped), for: .touchUpInside)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout
extension TrackersCollectionViewCell {
    
    private func configureUI(){
        guard let tracker = tracker else { return }
        checkButton.isSelected = false
        checkButton.backgroundColor = .clear
        checkButton.setImage(UIImage(named: "ButtonPlus")?.withRenderingMode(.alwaysTemplate), for: .normal)
        checkButton.tintColor = isSelected ? UIColor(named: "YP White"):UIColor(named: tracker.color)
        emojiTextField.text = tracker.emoji
        descriptionLabel.text = tracker.name
        cardView.backgroundColor = UIColor(named: tracker.color)
        counterLabel.text = String.localizedStringWithFormat(NSLocalizedString("Completed days", comment: "Number of completed days"), completedDays)
        completedDays = delegateVC?.countRecords(forUUID: tracker.id) ?? 6
        pinImageView.isHidden = !tracker.isPinned
    }
    
    private func addSubviews() {
        addSubview(cardView)
        cardView.addSubview(emojiTextField)
        cardView.addSubview(descriptionLabel)
        cardView.addSubview(pinImageView)
        addSubview(counterLabel)
        addSubview(checkButton)
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiTextField.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiTextField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiTextField.widthAnchor.constraint(equalToConstant: 24),
            emojiTextField.heightAnchor.constraint(equalToConstant: 24),
            
            descriptionLabel.topAnchor.constraint(equalTo: emojiTextField.bottomAnchor, constant: 8),
            descriptionLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            
            checkButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            checkButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            checkButton.heightAnchor.constraint(equalToConstant: 34),
            checkButton.widthAnchor.constraint(equalToConstant: 34),
            
            counterLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            counterLabel.trailingAnchor.constraint(equalTo: checkButton.leadingAnchor, constant: -8),
            counterLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 16),
            
            pinImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -4),
            pinImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            pinImageView.heightAnchor.constraint(equalToConstant: 24),
            pinImageView.widthAnchor.constraint(equalToConstant: 24)
        ])
    }
}

// MARK: - Cell's methods
extension TrackersCollectionViewCell{
    func set(with tracker: Tracker){
        self.tracker = tracker
    }
    
    func setCompletedTracker(){
        checkButton.isSelected = true
        checkButtonShouldTapped(with: checkButton.isSelected)
    }
    
    func getPreview() -> UITargetedPreview {
        return UITargetedPreview(view: cardView)
    }
}

// MARK: - Actions
private extension TrackersCollectionViewCell{
    @objc func checkButtonDidTapped(){
        guard let tracker = tracker else { return }
        let currentDay = delegateVC?.getCurrentDate() ?? Date()
        guard currentDay <= Date() else { return }
        
        checkButton.isSelected.toggle()
        if checkButton.isSelected{
            checkButtonShouldTapped(with: checkButton.isSelected)
            completedDays += 1
            delegateVC?.addCompletedTracker(tracker)
        } else{
            checkButtonShouldTapped(with: checkButton.isSelected)
            completedDays -= 1
            delegateVC?.removeCompletedTracker(tracker)
        }
    }
    
    func checkButtonShouldTapped(with selectedState:Bool){
        guard let tracker = tracker else { return }
        
        if selectedState {
            checkButton.backgroundColor = UIColor(named: tracker.color)
            checkButton.tintColor = UIColor(named: "YP White")
        } else{
            checkButton.backgroundColor = .clear
            checkButton.tintColor = UIColor(named: tracker.color)
        }
    }
}
