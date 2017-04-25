//
//  UploadViewController.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/25/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import UIKit
import Alamofire


class UploadViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func uploadPicture() {
    let url = "https://aui-lekssays.c9users.io/upload"
    let image = #imageLiteral(resourceName: "capitan")
    let imageData = UIImageJPEGRepresentation(image, 1.0)!
    Alamofire.upload(
      multipartFormData: { multipartFormData in
        multipartFormData.append(imageData, withName: "photo", fileName: "photo.jpg", mimeType: "image/jpg")
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
      }
    )    
  }

}
