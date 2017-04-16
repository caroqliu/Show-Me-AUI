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
  
  init?(jsonData: Any?) throws {
    guard let json = jsonData else {
      return nil
    }
    
    if let commentObject = json as? [String: Any] {
      // Get the comment text.
      guard let comment = commentObject[Comment.commentText] as? String else {
        throw SerializationError.missing(Comment.commentText)
      }
      
      // Get userImage.
      guard let userId = commentObject[Comment.userId] as? Int,
        let userImage = APIData.shared.getImage(url: "userImageForId", args: ["id": String(userId)]) else {
          throw SerializationError.missing(Comment.userId)
      }
      
      // Get userename.
      guard let resp = APIData.shared.getQuery(url: "userNameForId", args: ["id": String(userId)]) as? [String: String],
        let username = resp[Comment.username] else {
          throw SerializationError.missing(Comment.username)
      }
      
      self.comment = comment
      self.username = username
      self.userImage = userImage
    } else {
      return nil
    }
  }
}
