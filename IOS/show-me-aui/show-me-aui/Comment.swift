//
//  Comment.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/16/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import Foundation
import UIKit

struct Comment {
  var comment: String
  var username: String
  var userImage: UIImage
  
  static let commentText = "commentText"
  static let userId = "userId"
  static let username = "username"
  static let userImage = "userImage"
  
  init(json: [String: Any]) throws {
    // Get the comment text.
    guard let comment = json[Comment.commentText] as? String else {
      throw SerializationError.missing(Comment.commentText)
    }
    
    // Get userImage.
    guard let userId = json[Comment.userId] as? Int else {
      throw SerializationError.missing(Comment.userId)
    }
    
    let api = APIData.shared
    let downloadGroup = DispatchGroup()
    
    // Get userImage.
    var image: UIImage?
    downloadGroup.enter()
    api.queryServer(url: "/userImageForId", args: ["id": String(userId)]) { data in
      image = UIImage(data: data)
      downloadGroup.leave()
    }
    
    // Get userename.
    var name: String?
    downloadGroup.enter()
    api.queryServer(url: "/userNameForId", args: ["id": String(userId)]) { data in
      let jsonData = try! JSONSerialization.jsonObject(with: data)
      if let json = jsonData as? [String: String] {
        name = json[Comment.username]
        downloadGroup.leave()
      }
    }
    
    // Wait for username and image to be downloaded.
    downloadGroup.wait()
    
    guard let username = name else {
      throw SerializationError.missing(Comment.username)
    }
    
    guard let userImage = image else {
      throw SerializationError.missing(Comment.userImage)
    }
    
    self.comment = comment
    self.username = username
    self.userImage = userImage
  }
}
