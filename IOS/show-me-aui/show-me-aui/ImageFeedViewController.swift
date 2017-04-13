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
  let feedScrollView = UIScrollView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(feedScrollView)
    feedScrollView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    let pagelet = PageletView(userImage: UIImage(named: "user_icon")!, userName: "Achraf",
                              pageletImage: UIImage(named: "capitan")!)
    
    feedScrollView.addSubview(pagelet)
    pagelet.snp.makeConstraints { make in
      make.left.right.equalTo(feedScrollView)
      make.top.bottom.equalTo(feedScrollView)
    }
  }
}
