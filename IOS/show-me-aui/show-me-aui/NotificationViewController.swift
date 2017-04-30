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
  
  var imageId = 0
  
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
        var count = 0 // Count of new notification.
        for json in jsonArray {
          if let notification = Notification(json: json),
            !self.notificationIds.contains(notification.id) {
            // Increment number of new updates
            count = count + 1
            self.notifications.append(notification)
            self.notificationIds.insert(notification.id)
          }
        }
        
        DispatchQueue.main.async {
          // Show to the user the number of new updates.
          self.tabBarItem.badgeValue = String(count)

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
    let cell =
      tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath)
    cell.textLabel?.text = notifications[indexPath.row].message
    return cell
  }
  
}

extension NotificationViewController: UITableViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.isAtTop() {
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
    self.imageId = notifications[indexPath.row].imageId
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
