//
//  MainTabBarController.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/29/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import UIKit
import SQLite
import Alamofire
import SwiftyJSON

class MainTabBarController: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Force the notification view controller to be loaded.
    for controller in self.viewControllers! {
      if controller is NotificationViewController {
        _ = controller.view
      }
    }
    
    startTimer()
  }
  
  var timer: DispatchSourceTimer?
  
  func startTimer() {
    let queue = DispatchQueue.global(qos: .background)
    timer = DispatchSource.makeTimerSource(queue: queue)
    timer!.scheduleRepeating(deadline: .now(), interval: .seconds(30))
    timer!.setEventHandler { [weak self] in
      let url = API.UrlPaths.getUsers
      Alamofire.request(url).responseJSON(queue: DispatchQueue.global(qos: .background)) { response in
        switch response.result {
        case .success(let value):
          let users = API.DB.usersTable
          for (_, json) : (String, JSON) in JSON(value) {
            do {
              let db = try API.openDB()
              let row = try db.pluck(users.filter(API.DB.userId == json[API.Keys.userId].int!))
              
              if row == nil {
                try db.run(API.DB.usersTable.insert(
                  API.DB.userId <- json[API.Keys.userId].int!,
                  API.DB.userName <- json[API.Keys.userName].string!
                ))
              }
            } catch {
              print(error)
            }
          }
        case .failure(let error):
          print(error)
        }
      }
    }
    timer!.resume()
  }
  
  func stopTimer() {
    timer?.cancel()
    timer = nil
  }
  
  deinit {
    self.stopTimer()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
