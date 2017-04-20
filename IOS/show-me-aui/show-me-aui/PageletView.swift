//
//  PageletView.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/9/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import UIKit
import SnapKit

class PageletView: UIView, WriteCommentDelegate {
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
  
  // Id of the current image pagelet.
  let imageId: Int
  
  // Comments of the current pagelet.
  var comments = [Comment]()
  
  init?(imageId: Int) {
    self.imageId = imageId
    super.init(frame: CGRect.zero)
    
    fetchCommentsAsynchrounously()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // Height of the comments table.
  var currentCommentTableHeight: CGFloat {
    get {
      var height = CGFloat(0)
      for row in 0..<commentsTableView.numberOfRows(inSection: 0) {
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
  var currentPageLetHeight: CGFloat {
    get {
      return commentsTableView.frame.origin.y + currentCommentTableHeight
    }
  }
  
  init(userImage uimage: UIImage, userName name: String, pageletImage pimage: UIImage) {
    // TODO: Change
    self.imageId = 1
    super.init(frame: CGRect.zero)
    
    userImageView.image = uimage
    pageletImageView.image = pimage
    userNameLabel.text = name
    
    setUpUI()
    fetchCommentsAsynchrounously()
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
    
    self.addSubview(horizontalLine)
    horizontalLine.snp.makeConstraints { make in
      make.top.equalTo(likeButton.snp.bottom).offset(8)
      make.left.right.equalTo(self)
    }
    
    setUpCommentsTableView()
  }
  
  func setUpCommentsTableView() {
    commentsTableView.allowsSelection = false
    commentsTableView.separatorStyle = .none
    commentsTableView.estimatedRowHeight = 60
    commentsTableView.rowHeight = UITableViewAutomaticDimension
    
    commentsTableView.delegate = self
    commentsTableView.dataSource = self
    
    self.addSubview(commentsTableView)
    commentsTableView.snp.makeConstraints { make in
      make.top.equalTo(horizontalLine.snp.bottom).offset(8)
      make.left.right.bottom.equalTo(self)
      make.height.equalTo(currentCommentTableHeight)
    }
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
    
    // Get top ViewController, in order to push the WriteCommentViewController.
    var topVC = UIApplication.shared.keyWindow?.rootViewController
    while((topVC!.presentedViewController) != nil) {
      topVC = topVC!.presentedViewController
    }
    
    guard let rootVc = topVC else {
      fatalError("No root Vc.")
    }
    
    // Show WriteCommentViewController as a popup.
    // TODO: get current image id.
    let writeVc = WriteCommentViewController(imageId: 1)
    writeVc.delegate = self
    
    rootVc.addChildViewController(writeVc)
    writeVc.view.frame = rootVc.view.frame
    rootVc.view.addSubview(writeVc.view)
    writeVc.didMove(toParentViewController: rootVc)
  }
  
  // Fetch Comments asynchronously.
  func fetchCommentsAsynchrounously() {
    let api = APIData.shared
    let url = "/getCommentsForImageId"
    let args = ["id": String(self.imageId)]
    
    self.comments = []
    api.queryServer(url: url, args: args) { data in
      let jsonData = try! JSONSerialization.jsonObject(with: data)
      
      if let jsonArray = jsonData as? [[String: Any]] {
        DispatchQueue.global().async {
          // Group for fetching comments asynchrounsly.
          let commentsGroup = DispatchGroup()
          
          // Create comments from the json received.
          for i in 0..<jsonArray.count {
            do {
              commentsGroup.enter()
              self.comments.append(try Comment(json: jsonArray[i]))
              commentsGroup.leave()
            } catch {
              print(error)
            }
          }
          
          commentsGroup.wait()
          
          DispatchQueue.main.async {
            self.refreshComments()
          }
        }
      }
    }
  }
  
  // Reload data of the Comments table view.
  func refreshComments() {
    self.commentsTableView.reloadData()
    
    // Update autolayout.
    commentsTableView.snp.updateConstraints { make in
      make.height.equalTo(currentCommentTableHeight)
    }
  }
}

extension PageletView: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    // Only One section. All comments will be gathered in the same section.
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.comments.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell =  CommentCell()
    
    let comment = self.comments[indexPath.row]
    cell.commentLabel.text = comment.comment
    cell.userImageView.image = comment.userImage
    cell.userNameLabel.text = comment.username
    
    return cell
  }
}
