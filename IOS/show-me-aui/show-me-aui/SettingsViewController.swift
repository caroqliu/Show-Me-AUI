//
//  SettingsViewController.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/24/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, ProfileDelegate {
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  var userId: Int {
    return Session.shared.getUserIdForCurrentSession()!
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
  
  @IBAction func didTapMy() {
    print("didTapMy")
    performSegue(withIdentifier: "MySegue", sender: self)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "MySegue" {
      if let myVc = segue.destination as? ProfileViewController {
        myVc.delegate = self
      }
    }
  }
  
}
