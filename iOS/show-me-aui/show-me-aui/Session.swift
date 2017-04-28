//
//  Session.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/18/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import Foundation

class Session {
  static let shared = Session()
  
  // User defaults keys
  struct UserDefaultKey {
    static let userId = "userId"
  }
  
  private init() { }
  
  // Create a session for as user.
  // param @userId: user's identifier to whom the session will be created.
  func createSession(userId: Int) {
    let defaults = UserDefaults.standard
    debugPrint("Setting userId: ", userId)
    defaults.set(userId, forKey: UserDefaultKey.userId)
    if !defaults.synchronize() {
      NSLog("Could not synchronize userdefaults.")
    }
  }
  
  // Get the userId for the current session if exists.
  // returns the userId for the current session or nil if there is no active session.
  func getUserIdForCurrentSession() -> Int? {
    let defaults = UserDefaults.standard
    let userId = defaults.integer(forKey: UserDefaultKey.userId)
    if userId > 0 {
      // There is an active session.
      return userId
    }
    return nil
  }
  
  // Returns true if there is an active session, false otherwise.
  func isThereAnActiveSession() -> Bool {
    return getUserIdForCurrentSession() != nil
  }
  
  // Destroys current session.
  func destroyCurrentSession() {
    let defaults = UserDefaults.standard
    defaults.removeObject(forKey: UserDefaultKey.userId)
    if !defaults.synchronize() {
      NSLog("Could not synchronize userdefaults.")
    }
  }
}
