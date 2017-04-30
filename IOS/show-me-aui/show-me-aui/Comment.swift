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
import SwiftyJSON

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
          // Image was fetched successfully.
          image = UIImage(contentsOfFile: imagePath)
        } else {
          // No image found. Assign a placeholder.
          NSLog("Comment.init(json:): Could not get profile image.")
          image = #imageLiteral(resourceName: "profile-placeholder")
        }
        // Leave download group.
        downloadGroup.leave()
      }
    
    // Get userename.
    url = API.UrlPaths.userNameWithId
    var name: String?
    downloadGroup.enter()
    Alamofire.request(url, method: .get, parameters: parameters)
      .responseJSON { response in
        switch response.result {
        case .success(let value):
          let json = JSON(value)
          name = json[API.Keys.userName].string
        case .failure(let error):
          print(error)
        }
        // Leave download group.
        downloadGroup.leave()
      }
    
    // Wait for username and image to be downloaded for at most 20 seconds.
    let timeout = DispatchTime.now() + DispatchTimeInterval.seconds(20)
    if downloadGroup.wait(timeout: timeout) == .timedOut {
      throw SerializationError.timeout("Comment", json)
    }
    
    guard let username = name else {
      throw SerializationError.missing(API.Keys.userName)
    }
    
    self.comment = comment
    self.username = username
    self.userImage = image ?? #imageLiteral(resourceName: "profile-placeholder")
  }
}
