//
//  LoginBrain.swift
//
//
//  Created by Achraf Mamdouh on 4/11/17.
//
//

import Foundation

class LoginBrain {
  let serverUrl = ""
  
  func getDataFromServer() -> Data? {
    guard let requestUrl = URL(string:serverUrl) else {
      return nil
    }
    
    let request = URLRequest(url: requestUrl)
    let task = session.dataTask(with: request) {
      (data, response, error) in
      if error == nil {
        return data
      }
    }
  }
  
  func {
  }
}
