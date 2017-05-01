//
//  SettingsViewController.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/24/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func didTapLogout(_ sender: UIButton) {
    print("didTapLogout")
    Session.shared.destroyCurrentSession()
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let loginVc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
    
    let app = UIApplication.shared.delegate
    app?.window??.rootViewController = loginVc
  }
  
  @IBAction func didTapChangePassword() {
    print("didTapChangePassword")
  }
  
}
