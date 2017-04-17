//
//  CommentCell.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/17/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import UIKit
import SnapKit

class CommentCell: UITableViewCell {
  let userImageView = UIImageView()
  let userNameLabel = UILabel()
  let commentLabel = UILabel()
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    userImageView.layer.cornerRadius = 15
    userImageView.clipsToBounds = true
    self.contentView.addSubview(userImageView)
    
    userNameLabel.textColor = UIColor(red: 45, green: 96, blue: 0)
    userNameLabel.font = UIFont(name: "Chalkduster", size: 12)
    self.contentView.addSubview(userNameLabel)
    
    commentLabel.numberOfLines = 0
    commentLabel.font = UIFont(name: "GillSans", size: 14)
    commentLabel.textColor = UIColor(red: 21, green: 45, blue: 0)
    self.contentView.addSubview(commentLabel)
    
    userImageView.snp.makeConstraints { make in
      make.top.left.equalTo(self.contentView).offset(8)
      make.width.equalTo(30)
      make.height.equalTo(userImageView.snp.width)
    }
    
    userNameLabel.snp.makeConstraints { make in
      make.top.equalTo(contentView).offset(8)
      make.left.equalTo(userImageView.snp.right).offset(8)
      make.right.equalTo(contentView).offset(-4)
    }
    
    commentLabel.snp.makeConstraints { make in
      make.top.equalTo(userNameLabel.snp.bottom).offset(4)
      make.bottom.right.equalTo(contentView).offset(-4)
      make.left.equalTo(userImageView.snp.right).offset(8)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}

extension UIColor {
  convenience init(red: Int, green: Int, blue: Int) {
    assert(red >= 0 && red <= 255, "Invalid red component")
    assert(green >= 0 && green <= 255, "Invalid green component")
    assert(blue >= 0 && blue <= 255, "Invalid blue component")
    
    self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
  }
  
  convenience init(rgb: Int) {
    self.init(
      red: (rgb >> 16) & 0xFF,
      green: (rgb >> 8) & 0xFF,
      blue: rgb & 0xFF
    )
  }
}
