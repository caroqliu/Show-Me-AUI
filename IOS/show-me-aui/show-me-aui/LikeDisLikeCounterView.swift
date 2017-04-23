//
//  LikeDisLikeCounterView.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/20/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import UIKit
import SnapKit

class LikeDisLikeCounterView: UIView {
  private let likeCounter = UILabel()
  private let dislikeCounter = UILabel()
  private let heartImageView = UIImageView()
  private let thumbDownImageView = UIImageView()
  private let verticalLine = UIView()
  
  var numberOfLikes = 0 {
    didSet {
      likeCounter.text = String(numberOfLikes)
    }
  }
  
  var numberOfDislikes = 0 {
    didSet {
      dislikeCounter.text = String(numberOfDislikes)
    }
  }
  
  init() {
    super.init(frame: CGRect.zero)
    setupUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupUI() {
    // Setup likeCounter.
    likeCounter.text = String(self.numberOfLikes)
    likeCounter.font = UIFont.preferredFont(forTextStyle: .footnote)
    self.addSubview(likeCounter)
    likeCounter.snp.makeConstraints { make in
      make.left.top.bottom.equalTo(self)
    }
    
    // Setup heart Image.
    heartImageView.image = #imageLiteral(resourceName: "like_filled")
    self.addSubview(heartImageView)
    heartImageView.snp.makeConstraints { make in
      make.left.equalTo(likeCounter.snp.right).offset(2)
      make.top.bottom.equalTo(self)
      make.width.equalTo(self.snp.height)
    }
    
    // Setup vertical Line.
    verticalLine.layer.borderWidth = 1.0
    verticalLine.layer.borderColor = UIColor.black.cgColor
    self.addSubview(verticalLine)
    verticalLine.snp.makeConstraints { make in
      make.left.equalTo(heartImageView.snp.right).offset(4)
      make.top.bottom.equalTo(self)
      make.width.equalTo(1)
    }
    
    // Setup dislikeCounter.
    dislikeCounter.text = String(self.numberOfDislikes)
    self.addSubview(dislikeCounter)
    dislikeCounter.snp.makeConstraints { make in
      make.left.equalTo(verticalLine.snp.right).offset(4)
      make.top.bottom.equalTo(self)
    }
    
    // Setup thumbDown Image.
    thumbDownImageView.image = #imageLiteral(resourceName: "thumb_down_filled")
    self.addSubview(thumbDownImageView)
    thumbDownImageView.snp.makeConstraints { make in
      make.left.equalTo(dislikeCounter.snp.right).offset(2)
      make.top.bottom.right.equalTo(self)
      make.width.equalTo(heartImageView)
    }
  }
}
