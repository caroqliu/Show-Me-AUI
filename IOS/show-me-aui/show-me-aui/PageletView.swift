//
//  PageletView.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/9/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire

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
  private let likeCounter = LikeDisLikeCounterView()
  
  var heighConstaint: Constraint?
  
  // Id of the current image pagelet.
  let imageId: Int
  
  // Comments of the current pagelet.
  var comments = [Comment]()
  
  private var isHeartSelected = false {
    didSet {
      DispatchQueue.main.async {
        if self.isHeartSelected {
          self.likeButton.setImage(#imageLiteral(resourceName: "like_filled"), for: .normal)
          self.isThumbDownSelected = false
        } else {
          self.likeButton.setImage(#imageLiteral(resourceName: "like"), for: .normal)
        }
      }
    }
  }
  
  private var isThumbDownSelected = false {
    didSet {
      DispatchQueue.main.async {
        if self.isThumbDownSelected {
          self.thumbDownButton.setImage(#imageLiteral(resourceName: "thumb_down_filled"), for: .normal)
          self.isHeartSelected = false
        } else {
          self.thumbDownButton.setImage(#imageLiteral(resourceName: "thumb_down"), for: .normal)
        }
      }
    }
  }
  
  init(json: [String: Any]) throws {
    guard let imageId = json[API.Keys.imageId] as? Int else {
      throw SerializationError.missing(API.Keys.imageId)
    }
    
    guard let userId = json[API.Keys.userId] as? Int else {
      throw SerializationError.missing(API.Keys.userId)
    }
    
    guard let imagePath = json[API.Keys.imagePath] as? String else {
      throw SerializationError.missing(API.Keys.imagePath)
    }
    
    guard let currentUserId = Session.shared.getUserIdForCurrentSession() else {
      throw SerializationError.missing(API.Keys.userId)
    }
    
    self.imageId = imageId
    super.init(frame: CGRect.zero)
    
    // TODO: make sure the UI is setup before downloading data.
    self.setUpUI()
    
    DispatchQueue.global().async {
      // Download Section.
      let destination: DownloadRequest.DownloadFileDestination = { _, _ in
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filename = FileManager.randomFileName(length: 10) + ".jpg"
        let fileURL = documentsURL.appendingPathComponent(filename)
        
        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
      }
      
      // Download pagelet main image.
      var parameters: Parameters = [API.Keys.imagePath: imagePath]
      var url = API.UrlPaths.imageAtPath
      Alamofire.download(url, method: .get, parameters: parameters, encoding: URLEncoding.default,
                         headers: nil, to: destination)
        .response { response in
          if response.error == nil, let imagePath = response.destinationURL?.path {
            DispatchQueue.main.async {
              self.pageletImageView.image = UIImage(contentsOfFile: imagePath)
            }
          }
      }
      
      // Download userImage.
      parameters = [API.Keys.userId: userId]
      url = API.UrlPaths.userImageWithId
      Alamofire.download(url, method: .get, parameters: parameters, encoding: URLEncoding.default,
                         headers: nil, to: destination)
        .response { response in
          if response.error == nil, let imagePath = response.destinationURL?.path {
            DispatchQueue.main.async {
              // In case the image is not found on the server use a placeholder.
              let image = UIImage(contentsOfFile: imagePath) ?? #imageLiteral(resourceName: "profile-placeholder")
              self.userImageView.image = image
            }
          }
      }
      
      // Fetch username.
      parameters = [API.Keys.userId: userId]
      debugPrint(parameters)
      url = API.UrlPaths.userNameWithId
      Alamofire.request(url, method: .get, parameters: parameters)
        .responseJSON { response in
          let json = response.result.value as? [String: String]
          DispatchQueue.main.async {
            self.userNameLabel.text = json?[API.Keys.userName]
          }
        }
      
      // Fetch user preference of current image.
      parameters = [API.Keys.userId: currentUserId, API.Keys.imageId: imageId]
      url = API.UrlPaths.doesUserLikePictureWithId
      Alamofire.request(url, method: .get, parameters: parameters)
        .responseJSON { response in
          let json = response.result.value as? [String: Bool]
          self.isHeartSelected = json?[API.Keys.result] ?? false
        }
      
      url = API.UrlPaths.doesUserDislikePictureWithId
      Alamofire.request(url, method: .get, parameters: parameters)
        .responseJSON { response in
          let json = response.result.value as? [String: Bool]
          self.isThumbDownSelected = json?[API.Keys.result] ?? false
        }
      
      // Fetch number of likes and dislikes.
      parameters = [API.Keys.imageId: imageId]
      url = API.UrlPaths.numberOfLikes
      Alamofire.request(url, method: .get, parameters: parameters)
        .responseJSON { response in
          let json = response.result.value as? [String: Int]
          self.likeCounter.numberOfLikes = json?[API.Keys.result] ?? 0
        }
      
      parameters = [API.Keys.imageId: imageId]
      url = API.UrlPaths.numberOfDislikes
      Alamofire.request(url, method: .get, parameters: parameters)
        .responseJSON { response in
          let json = response.result.value as? [String: Int]
          self.likeCounter.numberOfDislikes = json?[API.Keys.result] ?? 0
        }
    }
    
    fetchCommentsAsynchrounously()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // Height of the comments table.
  var currentCommentTableHeight: CGFloat {
    get {
      let maxHeight = CGFloat(120)
      var height = CGFloat(0)
      for row in 0..<commentsTableView.numberOfRows(inSection: 0) {
        let cellPath = IndexPath(row: row, section: 0)
        if let cell = commentsTableView.cellForRow(at: cellPath) {
          height += cell.frame.height
        } else {
          height += commentsTableView.estimatedRowHeight
        }
      }
      return min(height, maxHeight)
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
    userImageView.image = #imageLiteral(resourceName: "profile-placeholder")
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
    pageletImageView.image = #imageLiteral(resourceName: "image_placeholder")
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
    commentsTableView.estimatedRowHeight = 40
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
    
    // Update counters.
    if self.isThumbDownSelected {
      self.likeCounter.numberOfDislikes -= 1
    }
    
    if !self.isHeartSelected {
      self.likeCounter.numberOfLikes += 1
    } else {
      self.likeCounter.numberOfLikes -= 1
    }
    
    isHeartSelected = isHeartSelected ? false : true
    
    let url = isHeartSelected ? API.UrlPaths.savelike : API.UrlPaths.removelike
    self.saveUserPreference(url: url)
  }
  
  func didTapThumbDown() {
    print("didTapThumbsDown")
    
    // Update counters.
    if self.isHeartSelected {
      self.likeCounter.numberOfLikes -= 1
    }
    
    if !self.isThumbDownSelected {
      self.likeCounter.numberOfDislikes += 1
    } else {
      self.likeCounter.numberOfDislikes -= 1
    }
    
    isThumbDownSelected = isThumbDownSelected ? false : true
    
    let url = isThumbDownSelected ? API.UrlPaths.saveDislike : API.UrlPaths.removeDislike
    self.saveUserPreference(url: url)
  }
  
  func saveUserPreference(url: String) {
    guard let userId = Session.shared.getUserIdForCurrentSession() else {
      fatalError()
    }
    
    let parameters: Parameters =
      [API.Keys.imageId: self.imageId, API.Keys.userId: userId]
    Alamofire.request(url, method: .get, parameters: parameters)
      .responseJSON { response in
        debugPrint(response)
      }
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
    //let writeVc = WriteCommentViewController(imageId: self.imageId)
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let writeVc =
      storyboard.instantiateViewController(withIdentifier: "WriteCommentStoryBoardID") as! WriteCommentViewController

    writeVc.delegate = self
    
    rootVc.addChildViewController(writeVc)
    writeVc.view.frame = rootVc.view.frame
    rootVc.view.addSubview(writeVc.view)
    writeVc.didMove(toParentViewController: rootVc)
  }
  
  // MARK: Convenience
  
  // Fetch Comments asynchronously.
  func fetchCommentsAsynchrounously() {
    self.comments = []
    let parameters: Parameters = [API.Keys.imageId: self.imageId]
    Alamofire.request(API.UrlPaths.commentsForImageId, method: .get, parameters: parameters)
      .responseJSON(queue: DispatchQueue.global()) { response in
        
        if let jsonArray = response.result.value as? [[String: Any]] {
          // Group for fetching comments asynchrounsly.
          let sync = DispatchGroup()
          
          // Create comments from the json received.
          for i in 0..<jsonArray.count {
            do {
              sync.enter()
              self.comments.append(try Comment(json: jsonArray[i]))
              sync.leave()
            } catch {
              print(error)
            }
          }
          
          sync.wait()
          self.refreshComments()
        }
        
      }
  }
  
  // Reload data of the Comments table view.
  func refreshComments() {
    DispatchQueue.main.async {
      self.commentsTableView.reloadData()
      // Update autolayout.
      self.commentsTableView.snp.updateConstraints { make in
        make.height.equalTo(self.currentCommentTableHeight)
      }
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
    cell.commentLabel.attributedText = CommentParser.processComment(comment.comment)
    cell.userImageView.image = comment.userImage
    cell.userNameLabel.text = comment.username
    
    return cell
  }
}

extension FileManager {
  static func randomFileName(length: Int) -> String {
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)
    
    var randomString = ""
    
    for _ in 0 ..< length {
      let rand = arc4random_uniform(len)
      var nextChar = letters.character(at: Int(rand))
      randomString += NSString(characters: &nextChar, length: 1) as String
    }
    
    return randomString
  }
}
