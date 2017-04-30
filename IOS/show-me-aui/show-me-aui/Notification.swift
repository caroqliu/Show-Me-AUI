//
//  Notification.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/30/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON

struct Notification {
  let id: Int
  let from: Int
  let to: Int
  let imageId: Int
  let message: String
  
  // Construct init for json.
  init?(json: [String: Any]) {
    let json = JSON(json)
    
    guard let id = json["notificationId"].int else {
      return nil
    }
    
    guard let from = json["sender"].int else {
      return nil
    }
    
    guard let to = json["receiver"].int else {
      return nil
    }
    
    guard let imageId = json["imageId"].int else {
      return nil
    }
    
    let sync = DispatchGroup()
    var name: String?
    let url = API.UrlPaths.userNameWithId
    let parameters: Parameters = [API.Keys.userId: from]
    
    sync.enter()
    Alamofire.request(url, method: .get, parameters: parameters)
      .responseJSON(queue: DispatchQueue.global()) { response in
        switch response.result {
        case .success(let value):
          let json = JSON(value)
          name = json[API.Keys.userName].string
        case .failure(let error):
          print(error)
        }
        sync.leave()
    }
    sync.wait()
    
    guard let senderName = name else {
      return nil
    }
    
    self.id = id
    self.from = from
    self.to = to
    self.imageId = imageId
    self.message = "\(senderName) tagged you in a post"
  }
}
