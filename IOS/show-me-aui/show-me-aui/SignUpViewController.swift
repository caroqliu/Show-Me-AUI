//
//  SignUpViewController.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/27/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import UIKit
import Alamofire
import UIView_Shake
import MRProgress

struct FormRequirements {
  static let usernameMinimumLength = 6
  static let passwordMinimumLength = 10
}


class SignUpViewController: UIViewController {
  @IBOutlet var backGesture: UITapGestureRecognizer!
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var firstnameTextField: UITextField!
  @IBOutlet weak var lastnameTextField: UITextField!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var passwordCheckerTextField: UITextField!
  @IBOutlet weak var errorLabel: UILabel!
  
  enum FormError {
    case missing(String)
    case invalid(String, String)
    case unknown
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Setup gestureRecognizer.
    backGesture.numberOfTapsRequired = 1
    backGesture.addTarget(self, action: #selector(didTapGoToLogin))
    
    // Setup errorLabel.
    errorLabel.numberOfLines = 0
    errorLabel.lineBreakMode = .byWordWrapping
  }
  
  func didTapGoToLogin() {
    print("didTapGoToLogin")
    performSegue(withIdentifier: "LoginSegue", sender: self)
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
  
  func isValidEmail(email: String) -> Bool {
    // print("validate calendar: \(testStr)")
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: email)
  }
  
  @IBAction func signUp() {
    print("didTapSignup")
    
    guard let username = usernameTextField.text, !username.isEmpty else {
      handleSignupError(error: .missing("username"))
      return
    }
    
    guard let firstname = firstnameTextField.text, !firstname.isEmpty else {
      handleSignupError(error: .missing("first name"))
      return
    }
    
    guard let lastname = lastnameTextField.text, !lastname.isEmpty else {
      handleSignupError(error: .missing("last name"))
      return
    }
    
    guard let email = emailTextField.text, !email.isEmpty else {
      handleSignupError(error: .missing("email"))
      return
    }
    
    if !isValidEmail(email: email) {
      handleSignupError(error: .invalid("email", "email not valid"))
      return
    }
    
    guard let password = passwordTextField.text, !password.isEmpty else {
      handleSignupError(error: .missing("password"))
      return
    }
    
    guard let passwordChecker = passwordCheckerTextField.text,
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
    
    let url = API.UrlPaths.addUser
    let parameters: Parameters =
      [API.Keys.userName: username,
       API.Keys.firstName: firstname,
       API.Keys.lastName: lastname,
       API.Keys.email: email,
       API.Keys.password: password]
    
    
    var progress = MRProgressOverlayView.showOverlayAdded(to: self.view,
                                                          title: "",
                                                          mode: .indeterminate,
                                                          animated: true)
    
    Alamofire.request(url, method: .post, parameters: parameters)
      .responseJSON { response in
        progress?.dismiss(true)

        // Check for status.
        if let json = response.result.value as? [String: Any],
          let status = json[API.Keys.result] as? Bool, !status {
          // Could not add user.
          DispatchQueue.main.async {
            progress = MRProgressOverlayView.showOverlayAdded(to: self.view,
                                                              title: "",
                                                              mode: .cross,
                                                              animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400) , execute: {
              progress?.dismiss(true)
            })
            
            if let which = json[API.Keys.which] as? String {
              self.handleSignupError(error: .invalid(which, "\(which) already exists"))
            } else {
              self.handleSignupError(error: .unknown)
            }
          }
        } else {
          // Signup successful.
          // Show checkmarck instead of current loading.
          progress = MRProgressOverlayView.showOverlayAdded(to: self.view,
                                                            title: "",
                                                            mode: .checkmark,
                                                            animated: true)
          
          // Redirect to login page after 1 seconds.
          DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            progress?.dismiss(true, completion: {
              self.performSegue(withIdentifier: "LoginSegue", sender: self)
            })
          })
        }
      }
  }

}
