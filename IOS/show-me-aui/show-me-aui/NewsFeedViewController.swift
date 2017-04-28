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
  
  // In order to allow only one update at a time.
  let updateSemaphore = DispatchSemaphore(value: 1)
  
  // Tells if an update is expected.
  var shouldScheduleUpdate = false
  
  // Ids of the pagelets in the newsfeed.
  var pageletsIds = Set<Int>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set the tab bar item for the news feed.
    self.tabBarItem = UITabBarItem(title: "News Feed", image: #imageLiteral(resourceName: "home"), tag: 0)

    // Setup UI.
    feedScrollView.delegate = self
    view.addSubview(feedScrollView)
    feedScrollView.snp.makeConstraints { make in
      make.left.right.bottom.equalTo(view)
      make.top.equalTo(view).offset(20)
    }
    
    feedScrollView.addSubview(contentView)
    contentView.snp.makeConstraints { make in
      make.edges.equalTo(feedScrollView)
    }
    
    // Setup footer view.
    contentView.addSubview(footer)
    
    // Update news feed.
    self.updateNewsFeed()
  }

  func updateNewsFeed() {
    // Arguments for querying the server.
    let url = API.UrlPaths.getPagelets
    let parameters: Parameters = ["offset": 0, "count": 5]
    
    // User in order to wait for server response.
    let sync = DispatchGroup()
    
    // Used to see if it is necessary to update the UI or not.
    var shouldUpdateUI = false
    
    // Will contain the views to add.
    var pagelets = [UIView]()
    
    // Start of request.
    sync.enter()
    Alamofire.request(url, method: .get, parameters: parameters)
      .responseJSON(queue: DispatchQueue.global()) { response in
        let jsonArray = response.result.value as! [[String: Any]]
        print(jsonArray)
        for pageletJson in jsonArray {
          do {
            if let id = pageletJson[API.Keys.imageId] as? Int {
              if !self.pageletsIds.contains(id) {
                // New pagelet.
                shouldUpdateUI = true
                self.pageletsIds.insert(id)
                let pagelet = try PageletView(json: pageletJson)
                pagelets.append(pagelet)
              }
            }
          } catch {
            print(error)
          }
        }
        sync.leave()
    }
    sync.wait()
    
    if !shouldUpdateUI {
      // No new pagelet.
      return
    }
    
    // Reverse order of the views, because they are inserted in the front of the content
    // view.
    pagelets = pagelets.reversed()
    
    DispatchQueue.main.async {
      // Update UI.
      
      // Add views to the content view.
      for pagelet in pagelets {
        self.contentView.insertSubview(pagelet, at: 0)
      }
      
      // Setup autolayout constraints.
      var topView = self.contentView
      var index = 1
      for pagelet in self.contentView.subviews {
        // Last view is footer, should skip it.
        if index == self.contentView.subviews.count {
          break
        }
        
        pagelet.snp.remakeConstraints { make in
          if index == 1 {
            make.top.equalTo(self.contentView)
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
      
      self.footer.snp.remakeConstraints { make in
        make.top.equalTo(topView.snp.bottom)
        make.left.right.bottom.equalTo(self.contentView)
        make.height.equalTo(60)
      }
    }
  }

}

// To Schedule updates.
extension NewsFeedViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.isAtTop() {
      shouldScheduleUpdate = true
    } else if self.shouldScheduleUpdate {
      self.shouldScheduleUpdate = false
      DispatchQueue.global().async {
        // Should not be in the main thread it may block it.
        self.updateSemaphore.wait()
        self.updateNewsFeed()
        self.updateSemaphore.signal()
      }
    }
  }
}

extension UIScrollView {
  func isAtTop() -> Bool {
    let offset = CGFloat(-50)
    return self.contentOffset.y < offset
  }
}
