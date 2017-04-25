//
//  ImageUploader.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/25/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import Foundation
import Alamofire

class PageletUploader {
  
  static func upload(image: UIImage) {
    // Url server address.
    let url = "https://aui-lekssays.c9users.io/upload"
    
    // Create data to send to server.
    let arg = ["userId": Session.shared.getUserIdForCurrentSession()]
    guard let imageData = UIImageJPEGRepresentation(image, 1.0),
      let jsonData = try? JSONSerialization.data(withJSONObject: arg) else {
        NSLog("Could not create data for upload.")
        return;
    }
    
    // Upload data.
    Alamofire.upload(
      multipartFormData: { multipartFormData in
        multipartFormData.append(imageData, withName: "photo", fileName: "photo.jpg", mimeType: "image/jpg")
        multipartFormData.append(jsonData, withName: "json", mimeType: "application/json")
      },
      to: url,
      encodingCompletion: { encodingResult in
        switch encodingResult {
        case .success(let upload, _, _):
          upload.responseJSON { response in
            debugPrint(response)
          }
        case .failure(let encodingError):
          print(encodingError)
        }
      })
  }
}
