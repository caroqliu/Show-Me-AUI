//
//  ImageFeedViewController.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/9/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire

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
    
    let url = API.UrlPaths.getPagelets
    let parameters: Parameters = ["offset": 0, "count": 5]
    
    let sync = DispatchGroup()
    
    sync.enter()
    Alamofire.request(url, method: .get, parameters: parameters)
      .responseJSON(queue: DispatchQueue.global()) { response in
        let jsonArray = response.result.value as! [[String: Any]]
        print(jsonArray)
        for pageletJson in jsonArray {
          do {
            self.pagelets.append(try PageletView(json: pageletJson))
          } catch {
            print(error)
          }
        }
        sync.leave()
      }
    
    sync.wait()
    
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
