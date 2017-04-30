//
//  NotificationTableViewController.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/29/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import UIKit
import Alamofire
import SnapKit

class NotificationViewController: UIViewController, PageletViewControllerDelegate {
  @IBOutlet weak var tableView: UITableView!
  
  var notifications = [Notification]()
  var notificationIds = Set<Int>()
  
  // Last selected image id.
  var imageId = 0
  
  // Number of Unread messages.
  var countOfUnreadNotifications = 0 {
    didSet {
      // If count changes, change value of the badge.
      DispatchQueue.main.async {
        if self.countOfUnreadNotifications > 0 {
          self.tabBarItem.badgeValue = String(self.countOfUnreadNotifications)
        } else {
          // For no notifications, don't show a badge value.
          self.tabBarItem.badgeValue = nil
        }
      }
    }
  }
  
  var shouldScheduleUpdate = false
  let semaphore = DispatchSemaphore(value: 1)
  
  override func loadView() {
    super.loadView()
    
    // Setup table View.
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.view.addSubview(self.tableView)
    self.tableView.snp.makeConstraints { make in
      make.top.equalTo(self.topLayoutGuide.snp.bottom)
      make.left.right.bottom.equalTo(self.view)
    }
    
    // Download notifications.
    self.downloadNotifications()
  }
  
  func downloadNotifications() {
    let url = API.UrlPaths.notificationsForUserId
    let parameters: Parameters =
      [API.Keys.userId: Session.shared.getUserIdForCurrentSession()!]
    Alamofire.request(url, parameters: parameters)
      .responseJSON(queue: DispatchQueue.global()) { response in
        // Get json response.
        guard let jsonArray = response.result.value as? [[String: Any]] else {
          NSLog("Could not parse json response for notification.")
          return
        }
        
        // Create notifications from the json.
        for json in jsonArray {
          if let notification = Notification(json: json),
            !self.notificationIds.contains(notification.id) {
            self.notifications.append(notification)
            self.notificationIds.insert(notification.id)
            if !notification.wasRead {
              // Increment number of new updates
              self.countOfUnreadNotifications += 1
            }
          }
        }
        
        DispatchQueue.main.async {
          // Relaod table.
          self.tableView.reloadData()
        }
    }
  }
  
}

extension NotificationViewController: UITableViewDataSource {
  // MARK: - Table view data source
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Notifications"
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.notifications.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell",
                                             for: indexPath) as! NoticationTableViewCell
    
    // Initialize members.
    let notification = notifications[indexPath.row]
    cell.messageLabel.text = notification.message
    cell.wasRead = notification.wasRead
    
    // Download 'sender' image profile.
    let url = API.UrlPaths.userImageWithId
    let parameters: Parameters = [API.Keys.userId: notification.from]
    Alamofire.download(url, method: .get, parameters: parameters,
                       encoding: URLEncoding.default, headers: nil, to: API.Keys.alamofireDownloadDestination)
      .response(queue: DispatchQueue.global(qos: .utility)) { response in
        if response.error == nil, let imagePath = response.destinationURL?.path {
          DispatchQueue.main.async {
            let image = UIImage(contentsOfFile: imagePath) ?? #imageLiteral(resourceName: "profile-placeholder")
            cell.profileImageView.image = image
          }
        }
      }
    
    return cell
  }
  
}

extension NotificationViewController: UITableViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.isAtTop {
      self.shouldScheduleUpdate = true
    } else if self.shouldScheduleUpdate {
      self.shouldScheduleUpdate = false
      
      DispatchQueue.global().async {
        self.semaphore.wait()
        self.downloadNotifications()
        self.semaphore.signal()
      }
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // Selected notification.
    let notification = notifications[indexPath.row]
    
    // Update imageId with the selected one.
    self.imageId = notification.imageId
    
    // Update server: set the notification as read.
    let url = API.UrlPaths.markNotificationAsRead
    let parameters: Parameters = [API.Keys.notificationId: notification.id]
    Alamofire.request(url, method: .get, parameters: parameters)
      .responseJSON(queue: DispatchQueue.global()) { response in
        switch response.result {
        case .success:
          print("Notification set as read.")
          break;
        case .failure(let error):
          print(error)
        }
      }
    
    performSegue(withIdentifier: "PageLetSegue", sender: self)
  }
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "PageLetSegue" {
      if let vc = segue.destination as? PageletViewController {
        vc.delegate = self
      }
    }
  }
  
}
