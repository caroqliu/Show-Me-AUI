//
//  MainTabBarController.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/29/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Force the notification view controller to be loaded.
    for controller in self.viewControllers! {
      if controller is NotificationViewController {
        _ = controller.view
      }
    }
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
