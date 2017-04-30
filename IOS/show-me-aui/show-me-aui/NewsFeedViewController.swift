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
import MRProgress

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
  
  // Called to filter page lets to load.
  var updatePredicate: ((Int) -> Bool)?

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
    self.updateNewsFeed() { _ in return true }
  }

  func updateNewsFeed(predicate: @escaping (Int)-> Bool) {
    // Maximum number of pagelets to add.
    let maximumNumberOfPageletsToLoad = 4
    
    // Arguments for querying the server.
    let url = API.UrlPaths.getPagelets
    
    // User in order to wait for server response.
    let sync = DispatchGroup()
    
    // Used to see if it is necessary to update the UI or not.
    var shouldUpdateUI = false
    
    // Will contain the views to add.
    var pagelets = [PageletView]()
    
    // Number of pagelets to load.
    var leftToLoad = maximumNumberOfPageletsToLoad
    
    // Start of request.
    sync.enter()
    Alamofire.request(url).responseJSON(queue: DispatchQueue.global()) { response in
      let jsonArray = response.result.value as! [[String: Any]]
      print(jsonArray)
      for pageletJson in jsonArray {
        do {
          if let id = pageletJson[API.Keys.imageId] as? Int {
            if !self.pageletsIds.contains(id) && leftToLoad > 0 && predicate(id) {
              // New pagelet.
              leftToLoad -= 1 // Decrement number of pagelets to load.
              shouldUpdateUI = true // Should update UI
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
    
    DispatchQueue.main.async {
      // Update UI.
      
      // Show to the user that an update is running.
      let networkActivityProgress =
        MRProgressOverlayView.showOverlayAdded(to: self.view,
                                               title: "Updating",
                                               mode: .indeterminate,
                                               animated: true)
      // Dismiss the notice after 1 second.
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
        networkActivityProgress?.dismiss(true)
      }
      
      // Add views to the content view.
      for pagelet in pagelets {
        // Should find the right place where to add the subview.
        // Pagelets are sorted using image, in descreasing order.
        var index = 0
        while true {
          if let p = self.contentView.subviews[index] as? PageletView {
            if p.imageId < pagelet.imageId {
              break
            }
          } else {
            break
          }
          index += 1
        }
        
        // Insert it inside the contentView.
        self.contentView.insertSubview(pagelet, at: index)
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
    if scrollView.isAboveTop {
      // Update is requested.
      self.shouldScheduleUpdate = true
      // Fetch only new pagelets.
      self.updatePredicate = { id in return id > self.pageletsIds.max() ?? Int.min }
    } else if scrollView.isBelowBottom {
      // Update is requested.
      shouldScheduleUpdate = true
      // Fetch old pagelets.
      self.updatePredicate = { id in return id < self.pageletsIds.min() ?? Int.max }
    } else if self.shouldScheduleUpdate {
      self.shouldScheduleUpdate = false
      DispatchQueue.global().async {
        // Should not be in the main thread it may block it.
        self.updateSemaphore.wait()
        self.updateNewsFeed(predicate: self.updatePredicate!)
        self.updateSemaphore.signal()
      }
    }
  }
}

extension UIScrollView {
  
  var isAboveTop: Bool {
    return contentOffset.y <= verticalOffsetForAboveTop
  }
  
  var isAtTop: Bool {
    return contentOffset.y <= verticalOffsetForTop
  }
  
  var isAtBottom: Bool {
    return contentOffset.y >= verticalOffsetForBottom
  }
  
  var isBelowBottom: Bool {
    return contentOffset.y >= verticalOffsetForBelowBottom
  }
  
  var updateOffset: CGFloat {
    return 150.0
  }
  
  var verticalOffsetForAboveTop: CGFloat {
    
    return verticalOffsetForTop - updateOffset
  }
  
  var verticalOffsetForBelowBottom: CGFloat {
    return verticalOffsetForBottom + updateOffset
  }
  
  var verticalOffsetForTop: CGFloat {
    let topInset = contentInset.top
    return -topInset
  }
  
  var verticalOffsetForBottom: CGFloat {
    let scrollViewHeight = bounds.height
    let scrollContentSizeHeight = contentSize.height
    let bottomInset = contentInset.bottom
    let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
    return scrollViewBottomOffset
  }
  
}
