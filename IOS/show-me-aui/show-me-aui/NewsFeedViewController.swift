//
//  ImageFeedViewController.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/9/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import UIKit
import SnapKit

class NewsFeedViewController: UIViewController {
  let feedScrollView = UIScrollView()
  let contentView = UIView()
  let footer = UIView()
  
  var pagelets = [PageletView]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set the tab bar item for the news feed.
    self.tabBarItem = UITabBarItem(title: "News Feed", image: #imageLiteral(resourceName: "home"), tag: 0)

    // Setup UI.
    view.addSubview(feedScrollView)
    feedScrollView.snp.makeConstraints { make in
      make.left.right.bottom.equalTo(view)
      make.top.equalTo(view).offset(20)
    }
    
    feedScrollView.addSubview(contentView)
    contentView.snp.makeConstraints { make in
      make.edges.equalTo(feedScrollView)
    }
    
    let sync = DispatchGroup()
    let api = APIData.shared
    let url = "/getAllPictures"
    
    var imageIds = [Int]()
    
    sync.enter()
    api.queryServer(url: url, args: [:]) { data in
      guard let jsonArray = try! JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
        print("Could not load json.")
        return
      }
      
      DispatchQueue.global().async {
        for pageletJson in jsonArray {
          guard let imageId = pageletJson["imageId"]! as? Int else {
            fatalError("Could not create get image id.")
          }
          imageIds.append(imageId)
        }
        sync.leave()
      }
    }
    
    sync.wait()
    
    for imageId in imageIds {
      if let pagelet = PageletView(imageId: imageId) {
        self.pagelets.append(pagelet)
      }
    }
    
    var topView = contentView
    var index = 1
    for pagelet in pagelets {
      self.contentView.addSubview(pagelet)
      pagelet.snp.makeConstraints { make in
        if index == 1 {
          make.top.equalTo(contentView)
        } else {
          make.top.equalTo(topView.snp.bottom).offset(8)
        }
        make.left.right.equalTo(self.contentView)
        make.width.equalTo(UIScreen.main.bounds.width)
      }
      
      // set topView to current pagelet.
      topView = pagelet
      index += 1
    }
  
    contentView.addSubview(footer)
    footer.snp.makeConstraints { make in
      make.top.equalTo(topView.snp.bottom)
      make.left.right.bottom.equalTo(contentView)
      make.height.equalTo(60)
    }
  }
}
