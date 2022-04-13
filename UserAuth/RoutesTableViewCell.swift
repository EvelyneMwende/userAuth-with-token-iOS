//
//  RoutesTableViewCell.swift
//  UserAuth
//
//  Created by Eclectics on 13/04/2022.
//

import UIKit

class RoutesTableViewCellViewModel{
    let entry: String?
    let exit_point: String?
    let price: Int?
    
    init(
        entry: String,
        exit_point: String,
        price: Int
    ){
        self.entry = entry
        self.exit_point = exit_point
        self.price = price
    }
}

class RoutesTableViewCell: UITableViewCell {
    
    static let identifier = "NewsTableViewCell"
    
    //subviews
    private let entryTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private let exitTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18 , weight: .semibold)
        return label
    }()
    
    private let priceTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20 , weight: .semibold)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //add subviews
        contentView.addSubview(entryTitleLabel)
        contentView.addSubview(exitTitleLabel)
        contentView.addSubview(priceTitleLabel)
    }
    
    required init?(coder: NSCoder){
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //giving subviews a frame
        entryTitleLabel.frame = CGRect(
              x: 10,
              y: 0,
              width: contentView.frame.size.width - 170,
              height: 50
        )
        
        exitTitleLabel.frame = CGRect(
              x: 10,
              y: 50,
              width:
                contentView.frame.size.width - 170,
              height:contentView.frame.size.height/2
        )
        
        priceTitleLabel.frame = CGRect(
              x: contentView.frame.size.width - 150,
              y: 5,
              width: 140,
              height:contentView.frame.size.height - 10 //5-point margin at top and bottom
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        entryTitleLabel.text = nil
        exitTitleLabel.text = nil
        priceTitleLabel.text = nil
        
    }
    
    //configure cells with a viewmodel
    func configure(with viewModel: RoutesTableViewCellViewModel ){
        entryTitleLabel.text = viewModel.entry
        exitTitleLabel.text = viewModel.exit_point
        priceTitleLabel.text = String(viewModel.price!)
        
        
        
    }


}
