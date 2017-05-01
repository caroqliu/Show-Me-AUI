//
//  PageletUploader.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/25/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import Foundation
import Alamofire

class PageletUploader {
  
  static func upload(image: UIImage, closure: ((Progress) -> Void)? = nil) {
    // Url server address.
    let url = "https://aui-lekssays.c9users.io/upload"
    
    // Create data to send to server.
    let arg = ["userId": Session.shared.getUserIdForCurrentSession()]
    
    // Set maximum compression.
    guard let imageData = UIImageJPEGRepresentation(image, 0.0),
      let jsonData = try? JSONSerialization.data(withJSONObject: arg) else {
        fatalError("Could not create data for image.")
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
          
          upload.uploadProgress { progress in
            closure?(progress)
            print(progress.fractionCompleted)
          }
        case .failure(let encodingError):
          print(encodingError)
        }
      })
  }
}
