//
//  PageletView.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/9/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import UIKit
import SnapKit

class PageletView: UIView {
  private let userImageView = UIImageView()
  private let addressLabel = UILabel()
  private let pageletImageView = UIImageView()
  private let userNameLabel = UILabel()
  private let likeButton = UIButton()
  private let thumbDownButton = UIButton()
  private let isFavoriteButton = UIButton()
  private let commentButton = UIButton()
  
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
      let width = UIScreen.main.bounds.width
      make.width.equalTo(width)
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
      make.bottom.equalTo(self).offset(-8)
    }
    
    setupThumbDown()
    setUpCommentButton()
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
      make.bottom.equalTo(likeButton)
    }
  }
  
  private var isHeartSelected = false
  func didTapLike() {
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
  
  func didTapComment() {
    print("didTapComment")
  }
  
}
