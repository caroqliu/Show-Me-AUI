//
//  APIData.swift
//  show-me-aui
//
//  Created by Achraf Mamdouh on 4/16/17.
//  Copyright © 2017 Achraf Mamdouh. All rights reserved.
//

import Foundation
import UIKit

class APIData {
  let serverUrl = "https://aui-lekssays.c9users.io/"
  
  // MARK: Shared Instance
  static let shared = APIData()
  
  private init() {}
  
  // Query the server using a get request.
  // param @url: indicated the url to query.
  // param @args: arguments in the get query.
  // returns a Foundation object from the JSON given by the Server, or nil if an error 
  // occurs
  func getQuery(url: String, args: [String:String]) -> Any? {
    // Create request url in order to query API.
    let url = URL(string: makeGetRequestUsing(url: url, args: args))
    
    // Semaphore in order to wait for the request to be fetched from the server.
    let semaphore = DispatchSemaphore(value: 0);
    
    var result: Any?
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
          result = try JSONSerialization.jsonObject(with: data)
        }
        semaphore.signal()
      }
      catch {
        print("Error deserializing JSON: \(error)")
      }
    }
    
    task.resume()
    semaphore.wait()
    
    return result
  }
  
  // Query the server for an image.
  // param @url: indicated the url to query.
  // param @args: arguments in the get query.
  // returns a UIImage or nil in case of failure.
  func getImage(url: String, args: [String:String]) -> UIImage? {
    // Create request url in order to query API.
    let url = URL(string: makeGetRequestUsing(url: url, args: args))
    
    // Semaphore in order to wait for the request to be fetched from the server.
    let semaphore = DispatchSemaphore(value: 0);
    
    var image: UIImage?
    let task = URLSession.shared.dataTask(with: url!) { data, response, error in
      guard error == nil else {
        NSLog(error as! String)
        semaphore.signal();
        return
      }
      
      // Get data From the server.
      if let data = data {
        // Create image from the data received.
        image = UIImage(data: data)
      }
      semaphore.signal()
    }
    
    task.resume()
    semaphore.wait()
    
    return image    
  }
  
  // MARK: Convenience
  func makeGetRequestUsing(url sub: String, args: [String:String]) -> String {
    var url = serverUrl + sub
    
    var argNumber = 1
    for (key, value) in args {
      let separator = (argNumber == 1) ? "?" : "&"
      url += "\(separator)\(key)=\(value)"
      argNumber += 1
    }
    
    print("URL-> \(url)")
    
    return url
  }
}
