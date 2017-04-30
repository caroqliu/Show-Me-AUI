//
//  PageletViewController.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/29/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import UIKit
import Alamofire

protocol PageletViewControllerDelegate {
  var imageId: Int {get}
}

class PageletViewController: UIViewController {
  var delegate: PageletViewControllerDelegate?
  var pagelet: PageletView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let delegate = delegate else {
      return
    }
    
    // Download data to load pagelet.
    let url = API.UrlPaths.pictureWithImageId
    let parameters: Parameters = [API.Keys.imageId: delegate.imageId]
    Alamofire.request(url, method: .get, parameters: parameters)
      .responseJSON(queue: DispatchQueue.global()) { response in
      guard let json = response.result.value as? [String: Any] else {
        return
      }
        
      do {
        self.self.pagelet = try PageletView(json: json)
        DispatchQueue.main.async {
          self.view.addSubview(self.pagelet!)
          self.pagelet?.snp.makeConstraints { make in
            make.left.right.equalTo(self.view)
            make.centerY.equalTo(self.view)
          }
        }
      } catch {
        print(error)
      }
    }
  }
  
}
