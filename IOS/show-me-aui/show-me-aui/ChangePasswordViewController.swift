//
//  ChangePasswordViewController.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/30/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import UIKit
import Alamofire
import UIView_Shake
import MRProgress

class ChangePasswordViewController: UIViewController {
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var retypeTextField: UITextField!
  @IBOutlet weak var submitButton: UIButton!
  @IBOutlet weak var errorLabel: UILabel!
  @IBOutlet weak var backButton: UIStackView!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let tap = UITapGestureRecognizer()
    tap.numberOfTapsRequired = 1
    tap.addTarget(self, action: #selector(didTapBackButton))
    backButton.addGestureRecognizer(tap)
  }
  
  enum FormError {
    case missing(String)
    case invalid(String, String)
    case unknown
  }
  
  func handleSignupError(error: FormError) {
    switch error {
    case .missing(let what):
      errorLabel.text = "\(what) cannot be empty."
    case .invalid(_, let errorMessage):
      errorLabel.text = "\(errorMessage)."
    case .unknown:
      errorLabel.text = "Internal error. Please try later."
    }
    errorLabel.isHidden = false
    errorLabel.shake(10, withDelta: 5, speed: 0.05)
  }

  @IBAction func didTapChangePassword() {
    guard let password = passwordTextField.text, !password.isEmpty else {
      handleSignupError(error: .missing("password"))
      return
    }
    
    guard let passwordChecker = retypeTextField.text,
      !passwordChecker.isEmpty else {
        handleSignupError(error: .missing("password"))
        return
    }
    
    if password != passwordChecker {
      handleSignupError(error: .invalid("password", "passwords do not match"))
      return
    }
    
    if password.characters.count < FormRequirements.passwordMinimumLength {
      handleSignupError(error: .invalid("password", "password should contain at least 10 characters"))
      return
    }
    
    let url = API.UrlPaths.changePassword
    let parameters: Parameters = [API.Keys.userId: Session.shared.getUserIdForCurrentSession()!,
                                  API.Keys.password: password]
    
    var progress = MRProgressOverlayView.showOverlayAdded(to: self.view,
                                                          title: "",
                                                          mode: .indeterminate,
                                                          animated: true)
    
    Alamofire.request(url, method: .get, parameters: parameters)
      .responseJSON(queue: DispatchQueue.main) { response in
        // Dismiss current loading.
        progress?.dismiss(true)

        switch response.result {
        case .success:
          // Show checkmarck instead of current loading.
          progress = MRProgressOverlayView.showOverlayAdded(to: self.view,
                                                            title: "",
                                                            mode: .checkmark,
                                                            animated: true)
          
          // Redirect to login page after 1 seconds.
          DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            progress?.dismiss(true, completion: {
              self.performSegue(withIdentifier: "SettingsSegue", sender: self)
            })
          })
        case .failure(let error):
          // Show cross instead of current loading.
          progress = MRProgressOverlayView.showOverlayAdded(to: self.view,
                                                            title: "",
                                                            mode: .cross ,
                                                            animated: true)
          print(error)
        }
      }
  }
  
  func didTapBackButton() {
    print("didTapBackButton")
    performSegue(withIdentifier: "SettingsSegue", sender: self)
  }
  
}
