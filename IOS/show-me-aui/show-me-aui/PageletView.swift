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
  private let likeCounter: LikeDisLikeCounterView
  
  // Id of the current image pagelet.
  let imageId: Int
  
  // Comments of the current pagelet.
  var comments = [Comment]()
  
  private var isHeartSelected = false {
    didSet {
      DispatchQueue.main.async { // Dispatch task asynchrounsly
        // Save Like in the database.
        guard let currentUserId = Session.shared.getUserIdForCurrentSession() else {
          fatalError("Could not get current user id while session is active.")
        }
        
        let sync = DispatchGroup()
        let api = APIData.shared
        let url = self.isHeartSelected ? "/saveLike" : "/removeLike"
        
        sync.enter()
        api.queryServer(url: url,
                       args: ["userId": String(currentUserId), "imageId": String(self.imageId)]) { _ in
          sync.leave()
        }
        
        // Update UI.
        if self.isHeartSelected {
          self.likeButton.setImage(#imageLiteral(resourceName: "like_filled"), for: .normal)
          self.thumbDownButton.setImage(#imageLiteral(resourceName: "thumb_down"), for: .normal)
        } else {
          self.likeButton.setImage(#imageLiteral(resourceName: "like"), for: .normal)
        }
        
        sync.wait()
        self.likeCounter.refreshCounters()
      }
    }
  }
  
  private var isThumbDownSelected = false {
    didSet {
      DispatchQueue.main.async { // Dispatch task asynchrounsly
        // Save/Remove DisLike from the database.
        guard let currentUserId = Session.shared.getUserIdForCurrentSession() else {
          fatalError("Could not get current user id while session is active.")
        }
        
        let sync = DispatchGroup()
        let api = APIData.shared
        let url = self.isThumbDownSelected ? "/saveDisLike" : "/removeDisLike"
        
        sync.enter()
        api.queryServer(url: url,
                       args: ["userId": String(currentUserId), "imageId": String(self.imageId)]) { _ in
          sync.leave()
        }
        
        // Update the UI.
        if self.isThumbDownSelected {
          self.thumbDownButton.setImage(#imageLiteral(resourceName: "thumb_down_filled"), for: .normal)
          self.likeButton.setImage(#imageLiteral(resourceName: "like"), for: .normal)
        } else {
          self.thumbDownButton.setImage(#imageLiteral(resourceName: "thumb_down"), for: .normal)
        }
        
        sync.wait()
        self.likeCounter.refreshCounters()
      }
    }
  }
  
  // Designated initializer.
  init?(imageId: Int) {
    // Initialize all members.
    self.imageId = imageId
    self.likeCounter = LikeDisLikeCounterView(forImageId: imageId)
    super.init(frame: CGRect.zero)
    
    // Query necessary elements for the pagelet.
    let api = APIData.shared
    var args: [String: String]
    let sync = DispatchGroup()
    guard let currentUserId = Session.shared.getUserIdForCurrentSession() else {
      return nil
    }
    
    // Fetch pagelet's main image.
    args = ["imageId": String(imageId)]
    sync.enter()
    api.queryServer(url: "/image", args: args) { data in
      self.pageletImageView.image = UIImage(data: data)
      sync.leave()
    }
    
    // Fetch userImage.
    args = ["id": String(currentUserId)]
    sync.enter()
    api.queryServer(url: "/userImageForId", args: args) { data in
      self.userImageView.image = UIImage(data: data)
      sync.leave()
    }
    
    // Fetch username.
    args = ["id": String(currentUserId)]
    sync.enter()
    api.queryServer(url: "/userNameForId", args: args) { data in
      let json = try! JSONSerialization.jsonObject(with: data) as? [String: String]
      self.userNameLabel.text = json?["username"]
      sync.leave()
    }
    
    // Fetch user preference of current image.
    args = ["userId": String(currentUserId), "imageId": String(imageId)]
    
    sync.enter()
    api.queryServer(url: "/doesUserLikePicture", args: args) { data in
      let json = try! JSONSerialization.jsonObject(with: data) as? [String: Bool]
      self.isHeartSelected = json?["result"] ?? false;
      sync.leave()
    }
    
    sync.enter()
    api.queryServer(url: "/doesUserDisLikePicture", args: args) { data in
      let json = try! JSONSerialization.jsonObject(with: data) as? [String: Bool]
      self.isThumbDownSelected = json?["result"] ?? false;
      sync.leave()
    }
    
    sync.wait()
    
    setUpUI()
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
  
  // MARK: UI
  
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
    pageletImageView.contentMode = .scaleAspectFit
    self.addSubview(pageletImageView)
    pageletImageView.snp.makeConstraints { make in
      make.left.right.equalTo(self)
      make.top.greaterThanOrEqualTo(addressLabel.snp.bottom).offset(8)
      make.top.greaterThanOrEqualTo(userImageView.snp.bottom).offset(8)
      
      let width = UIScreen.main.bounds.width
      let image = self.pageletImageView.image!
      let scale = image.size.height / image.size.width
      make.height.equalTo(width * scale)
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
    
    // Setup likeAndDislike Counters.
    self.addSubview(likeCounter)
    likeCounter.snp.makeConstraints { make in
      make.height.equalTo(15)
      make.right.equalTo(self).offset(-8)
      make.top.equalTo(pageletImageView.snp.bottom).offset(15)
    }
    
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
  
  // MARK: Targets
  
  func didTapLike() {
    print("didTapLike")
    isHeartSelected = isHeartSelected ? false : true
  }
  
  func didTapThumbDown() {
    print("didTapThumbsDown")
    isThumbDownSelected = isThumbDownSelected ? false : true
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
  
  // MARK: Convenience
  
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
