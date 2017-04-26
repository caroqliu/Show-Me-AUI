//
//  API.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/26/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import Foundation

class API {
  #if Debug
    static let host = "https://aui-lekssays.c9users.io"
  #else
    static let host = "https://showmeaui.herokuapp.com"
  #endif
  
  
  struct Keys {
    static let userName = "username"
    static let imageId = "imageId"
    static let userId = "userId"
    static let imagePath = "imagePath"
    static let result = "result"
    static let commentText = "commentText"
    static let email = "email"
    static let password = "password"
  }
    
  struct UrlPaths {
    static let authenticate =                 host + "/authenticate"
    static let commentsForImageId =           host + "/getCommentsForImageId"
    static let doesUserLikePictureWithId =    host + "/doesUserLikePicture"
    static let doesUserDislikePictureWithId = host + "/doesUserDisLikePicture"
    static let getPagelets =                  host + "/getAllPictures"
    static let imageAtPath =                  host + "/imageAtPath"
    static let numberOfLikes =                host + "/numberOfLikes"
    static let numberOfDislikes =             host + "/numberOfDisLikes"
    static let saveComment =                  host + "/saveComment"
    static let savelike =                     host + "/saveLike"
    static let saveDislike =                  host + "/saveDisLike"
    static let removelike =                   host + "/removeLike"
    static let removeDislike =                host + "/removeDisLike"
    static let userImageWithId =              host + "/userImageForId"
    static let userNameWithId =               host + "/userNameForId"
  }
  
}
