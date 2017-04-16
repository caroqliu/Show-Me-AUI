//
//  PageletView.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/9/17.
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

class PageletView: UIView {
  private let userImageView = UIImageView()
  private let addressLabel = UILabel()
  private let pageletImageView = UIImageView()
  private let userNameLabel = UILabel()
  private let likeButton = UIButton()
  private let thumbDownButton = UIButton()
  private let isFavoriteButton = UIButton()
  private let commentButton = UIButton()
  private let commentsTableView = UITableView()
  private let horizontalLine = UIView()
  
  // Height of the comments (calcualtes the height for at most 3) as only 3 are show at
  // a time.
  var commentTablePreviewHeight: CGFloat {
    get {
      var height = CGFloat(0)
      for row in 0..<min(3,commentsTableView.numberOfRows(inSection: 0)) {
        let cellPath = IndexPath(row: row, section: 0)
        if let cell = commentsTableView.cellForRow(at: cellPath) {
          height += cell.frame.height
        } else {
          height += commentsTableView.estimatedRowHeight
        }
      }
      return height
    }
  }
  
  // Height of the pageLetView.
  var currentHeight: CGFloat {
    get {
      return commentsTableView.frame.origin.y + commentTablePreviewHeight
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  init(userImage uimage: UIImage, userName name: String, pageletImage pimage: UIImage) {
    super.init(frame: CGRect.zero)
    
    userImageView.image = uimage
    pageletImageView.image = pimage
    userNameLabel.text = name
    
    setUpUI()
  }
  
  func setUpUI() {
    // Setup frame of the view.
    self.layer.cornerRadius = 10.0
    self.layer.borderWidth = 2.0
    self.layer.borderColor = UIColor.lightGray.cgColor
    
    // Setup userImageView.
    userImageView.layer.borderWidth = 1.0
    userImageView.layer.cornerRadius = 20
    userImageView.clipsToBounds = true
    
    self.addSubview(userImageView)
    userImageView.snp.makeConstraints { make in
      make.height.equalTo(40)
      make.width.equalTo(40)
      make.top.left.equalTo(self).offset(8)
    }
    
    // Setup userNameLabel.
    userNameLabel.font = UIFont.preferredFont(forTextStyle: .body)
    self.addSubview(userNameLabel)
    userNameLabel.snp.makeConstraints { make in
      make.top.equalTo(self).offset(12)
      make.left.equalTo(userImageView.snp.right).offset(8)
    }
    
    setUpAddressLabel()
    
    // Setup pageletImageView.
    self.addSubview(pageletImageView)
    pageletImageView.snp.makeConstraints { make in
      make.left.right.equalTo(self)
      make.top.equalTo(addressLabel.snp.bottom).offset(8)
      make.height.equalTo(pageletImageView.snp.width).multipliedBy(1.0)
    }
    
    // Setup likeButton.
    likeButton.setImage(#imageLiteral(resourceName: "like"), for: .normal)
    likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
    self.addSubview(likeButton)
    likeButton.snp.makeConstraints { make in
      make.top.equalTo(pageletImageView.snp.bottom).offset(8)
      make.left.equalTo(self).offset(8)
      make.width.equalTo(30)
      make.height.equalTo(likeButton.snp.width).multipliedBy(1.0)
    }
    
    setupThumbDown()
    setUpCommentButton()
    setUpCommentsTableView()
    
    self.addSubview(horizontalLine)
    horizontalLine.snp.makeConstraints { make in
      make.top.equalTo(likeButton.snp.bottom).offset(8)
      make.left.right.bottom.equalTo(self)
    }
  }
  
  func setUpCommentsTableView() {
    commentsTableView.isHidden = true
    commentsTableView.estimatedRowHeight = 60
    commentsTableView.rowHeight = UITableViewAutomaticDimension
    
    commentsTableView.delegate = self
    commentsTableView.dataSource = self
    
    self.addSubview(commentsTableView)
  }
  
  func setUpCommentButton() {
    commentButton.setImage(#imageLiteral(resourceName: "comment"), for: .normal)
    commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
    
    self.addSubview(commentButton)
    commentButton.snp.makeConstraints { make in
      make.top.equalTo(pageletImageView.snp.bottom).offset(8)
      make.left.equalTo(thumbDownButton.snp.right).offset(8)
      make.width.equalTo(30)
      make.height.equalTo(likeButton.snp.width).multipliedBy(1.0)
    }
  }
  
  func setUpAddressLabel() {
    addressLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
    // TODO: get localization from db.
    addressLabel.text = "Somewhere in the universe"
    
    self.addSubview(addressLabel)
    addressLabel.snp.makeConstraints { make in
      make.top.equalTo(userNameLabel.snp.bottom).offset(4)
      make.left.equalTo(userImageView.snp.right).offset(8)
    }
  }
  
  func setupThumbDown() {
    thumbDownButton.setImage(#imageLiteral(resourceName: "thumb_down"), for: .normal)
    thumbDownButton.addTarget(self, action: #selector(didTapThumbDown), for: .touchUpInside)
    
    self.addSubview(thumbDownButton)
    thumbDownButton.snp.makeConstraints { make in
      make.top.equalTo(pageletImageView.snp.bottom).offset(8)
      make.left.equalTo(likeButton.snp.right).offset(8)
      make.width.equalTo(likeButton)
      make.height.equalTo(thumbDownButton.snp.width).multipliedBy(1.0)
    }
  }
  
  private var isHeartSelected = false
  func didTapLike() {
    // TODO: record action in db.
    print("didTapLike")
    isHeartSelected = isHeartSelected ? false : true
    
    if !isHeartSelected {
      likeButton.setImage(#imageLiteral(resourceName: "like"), for: .normal)
      thumbDownButton.isHidden = false
      
      commentButton.snp.remakeConstraints { make in
        make.top.equalTo(pageletImageView.snp.bottom).offset(8)
        make.left.equalTo(thumbDownButton.snp.right).offset(8)
        make.width.equalTo(30)
        make.height.equalTo(likeButton.snp.width).multipliedBy(1.0)
      }
    } else {
      likeButton.setImage(#imageLiteral(resourceName: "like_filled"), for: .normal)
      thumbDownButton.isHidden = true
      
      commentButton.snp.remakeConstraints { make in
        make.top.equalTo(pageletImageView.snp.bottom).offset(8)
        make.left.equalTo(likeButton.snp.right).offset(8)
        make.width.equalTo(30)
        make.height.equalTo(likeButton.snp.width).multipliedBy(1.0)
      }
    }
  }
  
  private var isThumbDownSelected = false
  func didTapThumbDown() {
    // TODO: record action in db.
    print("didTapThumbsDown")
    isThumbDownSelected = isThumbDownSelected ? false : true
    
    if !isThumbDownSelected {
      thumbDownButton.setImage(#imageLiteral(resourceName: "thumb_down"), for: .normal)
      likeButton.isHidden = false
      thumbDownButton.snp.remakeConstraints { make in
        make.top.equalTo(pageletImageView.snp.bottom).offset(8)
        make.left.equalTo(likeButton.snp.right).offset(8)
        make.width.equalTo(likeButton)
        make.height.equalTo(thumbDownButton.snp.width).multipliedBy(1.0)
        make.bottom.equalTo(likeButton)        
      }
    } else {
      thumbDownButton.setImage(#imageLiteral(resourceName: "thumb_down_filled"), for: .normal)
      likeButton.isHidden = true
      thumbDownButton.snp.remakeConstraints { make in
        make.top.equalTo(pageletImageView.snp.bottom).offset(8)
        make.left.equalTo(self).offset(8)
        make.width.equalTo(likeButton)
        make.height.equalTo(thumbDownButton.snp.width).multipliedBy(1.0)
        make.bottom.equalTo(likeButton)
      }
    }
  }
  
  override func updateConstraints() {
    super.updateConstraints()
  }
  
  func didTapComment() {
    print("didTapComment")
    
    commentsTableView.isHidden = false
    
    horizontalLine.snp.remakeConstraints { make in
      make.top.equalTo(likeButton.snp.bottom).offset(8)
      make.left.right.equalTo(self)
    }
    
    commentsTableView.snp.remakeConstraints { make in
      make.top.equalTo(horizontalLine.snp.bottom).offset(8)
      make.left.right.bottom.equalTo(self)
      make.height.equalTo(commentTablePreviewHeight)
    }
  }
}

extension PageletView: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    // Only One section. All comments will be gathered in the same section.
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // TODO: Fetch #comments from db.
    return 2
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell =  CommentCell()
    
    // TODO: populate cell from db.
    cell.userImageView.image = #imageLiteral(resourceName: "user_icon")
    cell.userNameLabel.text = "Kakashi Senpai"
    cell.commentLabel.text = "belle tof ma cherie.\nTest Test\nBoum."
    
    return cell
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
