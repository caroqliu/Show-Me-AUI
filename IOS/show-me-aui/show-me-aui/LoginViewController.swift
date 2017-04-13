//
//  LoginViewController.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/8/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import UIKit
import SnapKit

class LoginViewController: UIViewController {
  private let loginBrain = LoginBrain()
  
  // UI Elements
  private let emailTextField = UITextField()
  private let passwordTextField = UITextField()
  private let loginButton = UIButton()
  private let welcomeLabel = UILabel()
  private let forgotPasswordButton = UIButton()
  private let createAccountButton = UIButton()
  private let errorMessageLabel = UILabel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  // MARK: Targets
  
  func didTapForgotPassword() {
    print("didTapForgotPassword")
  }
  
  func didTapCreateAccount() {
    print("didTapCreatAccount")
  }
  
  // Enum for common error messages while logging in.
  enum ErrorMessage {
    case emptyEmail
    case emptyPassword
    case wrongPassword
  }
  
  func didTapLogin() {
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
    
    if loginBrain.query(email: email, password: password) {
      // Logged in succesffully. Now Redirect to main page.
      performSegue(withIdentifier: "FeedSegue", sender: self)
    } else {
      // Failed to login.
      handleFailedAuthenticationWithCode(.wrongPassword)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destinationViewControlelr = segue.destination
    if let feedViewController = destinationViewControlelr as? ImageFeedViewController {
      
    }
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
  }
  
  // MARK: UI
  
  func setupUI() {
    setupBackground()
    setupWelcomeLabel()
    setupUserNameTextField()
    setupPasswordTextField()
    setupLoginButton()
    setupForgotPasswordButton()
    setUpCreateAccountButton()
    setUpVerticalLineBetweenForgotButtonAndCreateButton()
    setUpErrorMessage()
  }
  
  func setUpErrorMessage() {
    errorMessageLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
    errorMessageLabel.textColor = UIColor.red
    errorMessageLabel.isHidden = true
    
    view.addSubview(errorMessageLabel)
    errorMessageLabel.snp.makeConstraints { make in
      make.top.equalTo(createAccountButton.snp.bottom).offset(8)
      make.centerX.equalTo(view)
    }
  }
  
  func setupBackground() {
    view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "capitan"))
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
    let blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView.frame = view.bounds
    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(blurEffectView)
  }
  
  func setupWelcomeLabel() {
    welcomeLabel.numberOfLines = 0
    welcomeLabel.text = "Login or Create a new account."
    welcomeLabel.textColor = UIColor.white
    
    view.addSubview(welcomeLabel)
    welcomeLabel.snp.makeConstraints { make in
      make.centerX.equalTo(view)
      make.top.equalTo(view).offset(50)
      make.height.equalTo(100)
      
    }
  }
  
  func setupUserNameTextField() {
    emailTextField.placeholder = "email"
    emailTextField.layer.borderWidth = 1.0
    emailTextField.layer.borderColor = UIColor.lightGray.cgColor
    emailTextField.layer.cornerRadius = 13.0
    emailTextField.leftViewMode = UITextFieldViewMode.always
    let userNameSpacerView = UIView(frame:CGRect(x:0, y:0, width:20, height:10))
    emailTextField.leftView = userNameSpacerView
    
    view.addSubview(emailTextField)
    emailTextField.snp.makeConstraints { make in
      make.centerX.equalTo(view)
      make.top.equalTo(welcomeLabel.snp.bottom).offset(40)
      make.width.equalTo(300)
      make.height.equalTo(30)
    }
  }
  
  func setupPasswordTextField() {
    passwordTextField.placeholder = "password"
    passwordTextField.isSecureTextEntry = true
    passwordTextField.layer.borderWidth = 1.0
    passwordTextField.layer.borderColor = UIColor.lightGray.cgColor
    passwordTextField.layer.cornerRadius = 13.0
    passwordTextField.leftViewMode = UITextFieldViewMode.always
    let spacerView = UIView(frame:CGRect(x:0, y:0, width:20, height:10))
    passwordTextField.leftView = spacerView
    
    view.addSubview(passwordTextField)
    passwordTextField.snp.makeConstraints { make in
      make.top.equalTo(emailTextField.snp.bottom).offset(8)
      make.width.equalTo(emailTextField)
      make.height.equalTo(emailTextField)
      make.centerX.equalTo(emailTextField)
    }
  }
  
  func setupLoginButton() {
    loginButton.setTitle("Login", for: .normal)
    loginButton.titleLabel?.textAlignment = .center
    loginButton.backgroundColor = UIColor.blue
    loginButton.layer.cornerRadius = 13.0
    loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
    
    view.addSubview(loginButton)
    loginButton.snp.makeConstraints{ make in
      make.top.equalTo(passwordTextField.snp.bottom).offset(8)
      make.width.equalTo(emailTextField)
      make.height.equalTo(emailTextField)
      make.centerX.equalTo(emailTextField)
    }
  }
  
  func setupForgotPasswordButton() {
    forgotPasswordButton.setTitle("Forgot Password ?", for: .normal)
    forgotPasswordButton.titleLabel?.textColor = UIColor.white
    forgotPasswordButton.titleLabel?.font = UIFont(name: "Damascus", size: 12.0)
    forgotPasswordButton.titleLabel?.textAlignment = .center
    forgotPasswordButton.layer.borderWidth = 0.0
    forgotPasswordButton.addTarget(self, action: #selector(didTapForgotPassword), for: .touchUpInside)
    
    view.addSubview(forgotPasswordButton)
    forgotPasswordButton.snp.makeConstraints { make in
      make.top.equalTo(loginButton.snp.bottom).offset(8)
      make.left.equalTo(loginButton)
      make.height.equalTo(30)
    }
    forgotPasswordButton.titleLabel?.snp.makeConstraints { make in
      make.edges.equalTo(forgotPasswordButton)
    }
  }
  
  func setUpVerticalLineBetweenForgotButtonAndCreateButton() {
    let verticalLineView = UIView()
    verticalLineView.layer.borderWidth = 1.0
    verticalLineView.layer.borderColor = UIColor.white.cgColor
    
    view.addSubview(verticalLineView)
    verticalLineView.snp.makeConstraints { make in
      make.top.equalTo(loginButton.snp.bottom).offset(10)
      make.width.equalTo(1)
      make.height.equalTo(15)
      make.left.equalTo(forgotPasswordButton.snp.right)
      make.right.equalTo(createAccountButton.snp.left)
    }
  }
  
  func setUpCreateAccountButton() {
    // Setup createAccountButton
    createAccountButton.setTitle("Create Account", for: .normal)
    createAccountButton.titleLabel?.textColor = UIColor.white
    createAccountButton.titleLabel?.font = UIFont(name: "Damascus", size: 12.0)
    createAccountButton.titleLabel?.textAlignment = .center
    createAccountButton.layer.borderWidth = 0.0
    createAccountButton.addTarget(self, action: #selector(didTapCreateAccount), for: .touchUpInside)
    
    view.addSubview(createAccountButton)
    createAccountButton.snp.makeConstraints { make in
      make.top.equalTo(loginButton.snp.bottom).offset(8)
      make.right.equalTo(loginButton)
      make.height.equalTo(forgotPasswordButton)
      make.width.equalTo(forgotPasswordButton)
    }
    createAccountButton.titleLabel?.snp.makeConstraints { make in
      make.edges.equalTo(createAccountButton)
    }
  }
}
