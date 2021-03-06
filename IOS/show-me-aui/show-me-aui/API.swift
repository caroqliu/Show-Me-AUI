//
//  API.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/26/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import Foundation
import SQLite
import Alamofire

class API {
  #if Debug
    static let host = "https://aui-lekssays.c9users.io"
  #else
    static let host = "https://showmeaui.herokuapp.com"
  #endif

  struct Keys {
    static let userName = "userName"
    static let imageId = "imageId"
    static let userId = "userId"
    static let imagePath = "imagePath"
    static let result = "result"
    static let commentText = "commentText"
    static let email = "email"
    static let password = "password"
    static let firstName = "firstName"
    static let lastName = "lastName"
    static let which = "which"
    static let notificationId = "notificationId"
    
    
    // Alamofire download destination.
    static let alamofireDownloadDestination: DownloadRequest.DownloadFileDestination = { _, _ in
      let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      let filename = FileManager.randomFileName(length: 10) + ".jpg"
      let fileURL = documentsURL.appendingPathComponent(filename)
      return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
    }
  }
  
  struct UrlPaths {
    static let addUser =                      host + "/addUser"
    static let authenticate =                 host + "/authenticate"
    static let changePassword =               host + "/changePassword"
    static let commentsForImageId =           host + "/getCommentsForImageId"
    static let doesUserLikePictureWithId =    host + "/doesUserLikePicture"
    static let doesUserDislikePictureWithId = host + "/doesUserDisLikePicture"
    static let getPagelets =                  host + "/getAllPictures"
    static let getUsers =                     host + "/getUsers"
    static let imageAtPath =                  host + "/imageAtPath"
    static let insertNotification =           host + "/insertNotification"
    static let isUserNameAvailable =          host + "/isUserNameAvailable"
    static let markNotificationAsRead =       host + "/markNotificationAsRead"
    static let notificationsForUserId =       host + "/getNotificationsForUserId"
    static let numberOfLikes =                host + "/numberOfLikes"
    static let numberOfDislikes =             host + "/numberOfDisLikes"
    static let picturesForUserId =            host + "/picturesForUserId"
    static let pictureWithImageId =           host + "/pictureWithImageId"
    static let saveComment =                  host + "/saveComment"
    static let savelike =                     host + "/saveLike"
    static let saveDislike =                  host + "/saveDisLike"
    static let removelike =                   host + "/removeLike"
    static let removeDislike =                host + "/removeDisLike"
    static let userImageWithId =              host + "/userImageForId"
    static let userNameWithId =               host + "/userNameForId"
  }
  
  struct DB {
    static let usersTable = Table("Users")
    static let userName = Expression<String>("userName")
    static let userId = Expression<Int>("userId")
  }
  
  static var db: Connection?
  
  static func openDB() throws -> Connection {
    if db == nil {
      let path = NSSearchPathForDirectoriesInDomains(
        .documentDirectory, .userDomainMask, true
        ).first!
      db = try Connection("\(path)/db.sqlite3")
    }
    return db!
  }
  
}
