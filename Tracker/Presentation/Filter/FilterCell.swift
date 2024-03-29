//
//  FilterCell.swift
//  Tracker
//
//  Created by Georgy on 16.10.2023.
//

import UIKit

final class FilterCell: UITableViewCell{
    static let reuseId = "FilterCell"
    
    var checkmarkImageView:UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "CustomCheckmark"))
        imageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor(named: "YP Background")
        self.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        self.textLabel?.textColor = UIColor(named: "YP Black")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(with filter:String, selected:Bool){
        self.textLabel?.text = filter
        if selected {
            self.accessoryView = checkmarkImageView
        }
    }
}
