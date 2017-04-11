//
//  LoginBrain.swift
//
//
//  Created by Achraf Mamdouh on 4/11/17.
//
//

import Foundation

class LoginBrain {
  let serverUrl = "https://aui-lekssays.c9users.io/authenticate"
  
  func createGetRequestForEmail(email: String, password: String) -> String {
    NSLog("\(serverUrl)?email=\(email)&password=\(password)")
    return "\(serverUrl)?email=\(email)&password=\(password)"
  }
  
  func query(email: String, password: String) -> Bool {
    // Create request url in order to query API.
    let url = URL(string: createGetRequestForEmail(email: email, password: password))
    
    // Semaphore in order to wait for the request to be fetched from the server.
    let semaphore = DispatchSemaphore(value: 0);
    
    var isValid = false
    let task = URLSession.shared.dataTask(with: url!) { data, response, error in
      guard error == nil else {
        NSLog(error as! String)
        semaphore.signal();
        return
      }
      
      do {
        // Get data From the server.
        if let data = data {
          // Parse data from the server as JSON.
          let json = try JSONSerialization.jsonObject(with: data) as! [String: Bool]
          if let result = json["result"], result {
            // Succesful authentication.
            isValid = true
          }
        }
        semaphore.signal()
      }
      catch {
        print("Error deserializing JSON: \(error)")
      }
    }
    
    task.resume()
    semaphore.wait()
    
    return isValid
  }
}
