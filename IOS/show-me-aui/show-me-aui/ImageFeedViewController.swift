//
//  ImageFeedViewController.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/9/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import UIKit
import SnapKit

class ImageFeedViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let pagelet = PageletView(userImage: UIImage(named: "user_icon")!, userName: "Achraf",
                              pageletImage: UIImage(named: "capitan")!)
    
    view.addSubview(pagelet)
    pagelet.snp.makeConstraints { make in
      make.left.right.equalTo(view)
      make.top.equalTo(view).offset(20)
    }
  }
}
