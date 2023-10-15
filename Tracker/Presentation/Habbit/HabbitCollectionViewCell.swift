//
//  HabbitCollectionViewCell.swift
//  Tracker
//
//  Created by Georgy on 28.08.2023.
//

import UIKit

class HabbitCollectionViewCell:UICollectionViewCell{
    
    // MARK: - Variables
    static let reuseId = "HabbitCollectionViewCell"

    private let Emojes = ["🙂","😻","🌺","🐶","❤️","😱","😇","😡","🥶","🤔","🙌","🍔","🥦","🏓","🥇","🎸","🏝️","😪"]
    
    weak var delegateVC: HabbitViewControllerProtocol?
    
    // MARK: - UI Elements
    private let textField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 8
        textField.backgroundColor = .clear
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        textField.isUserInteractionEnabled = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        applyConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.clipsToBounds = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Layout
extension HabbitCollectionViewCell {
    
    private func addSubviews() {
        addSubview(textField)
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
        ])
    }
}

extension HabbitCollectionViewCell{
    func set(with indexPath:IndexPath, _ emoji:String, _ color:String){
        switch indexPath.section{
        case 1:
            textField.text = Emojes[indexPath.row]
            if emoji == Emojes[indexPath.row] {
                delegateVC?.selectItem(at: indexPath)
                isSelected(for: indexPath)
            }
        case 2:
            textField.backgroundColor = UIColor(named: "Color selection \(indexPath.row + 1)")
            if color == "Color selection \(indexPath.row + 1)" {
                delegateVC?.selectItem(at: indexPath)
                isSelected(for: indexPath)
            }
        default:
            break
        }
    }
    
    func isSelected(for indexPath:IndexPath){
        switch indexPath.section{
        case 1:
            self.backgroundColor = UIColor(named: "YP Light Gray")
            self.layer.cornerRadius = 16
            
            guard let emoji = textField.text else { return }
            delegateVC?.setEmoji(emoji)
        case 2:
            let borderColor = UIColor(named: "Color selection \(indexPath.row + 1)")?.withAlphaComponent(0.5).cgColor
            self.layer.cornerRadius = 8
            self.layer.borderColor = borderColor
            self.layer.borderWidth = 3
            
            delegateVC?.setColor("Color selection \(indexPath.row + 1)")
        default:
            break
        }
    }
    
    func isDeselected(for indexPath:IndexPath){
        switch indexPath.section{
        case 1:
            self.backgroundColor = .clear
            
            delegateVC?.setEmoji("")
        case 2:
            self.layer.borderColor = nil
            self.layer.borderWidth = 0
            
            delegateVC?.setColor("")
        default:
            break
        }
    }
}
