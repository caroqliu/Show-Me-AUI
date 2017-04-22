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
      make.left.right.bottom.equalTo(view)
      make.top.equalTo(view).offset(20)
    }
    
    guard let pagelet = PageletView(imageId: 1) else {
      fatalError()
    }
    
    feedScrollView.addSubview(pagelet)
    pagelet.snp.makeConstraints { make in
      make.left.equalTo(feedScrollView)
      let width = UIScreen.main.bounds.width
      make.width.equalTo(width)
      make.top.bottom.equalTo(feedScrollView)
    }
  }
}
