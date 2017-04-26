//
//  Comment.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/16/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

struct Comment {
  var comment: String
  var username: String
  var userImage: UIImage
  
  init(json: [String: Any]) throws {
    // Get the comment text.
    guard let comment = json[API.Keys.commentText] as? String else {
      throw SerializationError.missing(API.Keys.commentText)
    }
    
    // Get userImage.
    guard let userId = json[API.Keys.userId] as? Int else {
      throw SerializationError.missing(API.Keys.userId)
    }
    
    // Download Section.
    let downloadGroup = DispatchGroup()
    let parameters: Parameters = [API.Keys.userId: userId]
    let destination: DownloadRequest.DownloadFileDestination = { _, _ in
      let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      let filename = FileManager.randomFileName(length: 10) + ".jpg"
      let fileURL = documentsURL.appendingPathComponent(filename)
      
      return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
    }
    
    // Get userImage.
    var url = API.UrlPaths.userImageWithId
    var image: UIImage?
    downloadGroup.enter()
    Alamofire.download(url, method: .get, parameters: parameters, encoding: URLEncoding.default,
                       headers: nil, to: destination)
      .response { response in
        if response.error == nil, let imagePath = response.destinationURL?.path {
          image = UIImage(contentsOfFile: imagePath)
          downloadGroup.leave()
        }
    }
    
    // Get userename.
    url = API.UrlPaths.userNameWithId
    var name: String?
    downloadGroup.enter()
    Alamofire.request(url, method: .get, parameters: parameters)
      .responseJSON { response in
        if let json = response.result.value as? [String: String] {
          name = json[API.Keys.userName]
          downloadGroup.leave()
        }
      }
    
    // Wait for username and image to be downloaded.
    downloadGroup.wait()
    
    guard let username = name else {
      throw SerializationError.missing(API.Keys.userName)
    }
    
    guard let userImage = image else {
      throw SerializationError.missing("No user image");
    }
    
    self.comment = comment
    self.username = username
    self.userImage = userImage
  }
}
