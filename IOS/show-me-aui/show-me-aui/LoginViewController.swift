//
//  LoginViewController.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/8/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire
import UIView_Shake
import MRProgress

class LoginViewController: UIViewController {
  
  // UI Elements
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var createAccountButton: UIButton!
  @IBOutlet weak var forgotPasswordButton: UIButton!
  @IBOutlet weak var errorMessageLabel: UILabel!
  @IBOutlet weak var signinForm: UIStackView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Initialize the view only if no user is logged in.
    if Session.shared.isThereAnActiveSession() {
      self.signinForm.isHidden = true
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    // Check if a user is already logged in.
    if Session.shared.isThereAnActiveSession() {
      // A user is logged in, no need to prompt the user for his credetials.
      // Redirect to main page.
      performSegue(withIdentifier: "FeedSegue", sender: self)
    }
  }
  
  // Enum for common error messages while logging in.
  enum ErrorMessage {
    case emptyEmail
    case emptyPassword
    case wrongPassword
  }
  
  func handleFailedAuthenticationWithCode(_ code: ErrorMessage) {
    var errorMessage: String
    switch code {
    case .emptyPassword:
      errorMessage = "Password cannot be empty."
    case .emptyEmail:
      errorMessage = "Email cannot be empty."
    case .wrongPassword:
      errorMessage = "Wrong Email/Password combination."
    }
    
    errorMessageLabel.text = errorMessage
    errorMessageLabel.isHidden = false
    errorMessageLabel.shake(10, withDelta: 5, speed: 0.05)
  }

  
  // MARK: Targets
  
  @IBAction func didTapForgotPassword() {
    print("didTapForgotPassword")
  }
  
  @IBAction func didTapCreateAccount() {
    print("didTapCreatAccount")
    performSegue(withIdentifier: "SignupSegue", sender: self)
  }
  
  @IBAction func didTapLogin() {
    guard let email = emailTextField.text, !email.isEmpty else {
      // Empty email.
      handleFailedAuthenticationWithCode(.emptyEmail)
      return
    }
    
    guard let password = passwordTextField.text, !password.isEmpty else {
      // Empty password.
      handleFailedAuthenticationWithCode(.emptyPassword)
      return
    }
    
    var signinProgress = MRProgressOverlayView.showOverlayAdded(to: self.view,
                                                                animated: true)
    
    // Authenticate.
    let url = API.UrlPaths.authenticate
    let parameters: Parameters = [API.Keys.email: email, API.Keys.password: password]
    Alamofire.request(url, method: .get, parameters: parameters)
      .responseJSON { response in
        debugPrint(response.result.value as? [String: Int] ?? "Empty response")
        if let resp = response.result.value as? [String: Int],
          let userId = resp[API.Keys.userId], userId > 0 {
          // Logged in succesffully.
          
          // Create session for current user.
          let session = Session.shared
          session.createSession(userId: userId)
          
          // Show to the user a check mark.
          signinProgress?.dismiss(true)
          signinProgress = MRProgressOverlayView.showOverlayAdded(to: self.view,
                                                                  title: "",
                                                                  mode: .checkmark,
                                                                  animated: true)
          
          // Redirect to main page after half a second.
          DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            signinProgress?.dismiss(true)
            self.performSegue(withIdentifier: "FeedSegue", sender: self)
          })
        } else {
          // Failed to login.
          signinProgress?.dismiss(true)
          self.handleFailedAuthenticationWithCode(.wrongPassword)
        }
    }
  }
  
}
