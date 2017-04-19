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
    let url = makeGetRequestUsing(url: url, args: args)
    
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
  
  // Query the server using a get request.
  // param @url: indicated the url to query.
  // param @args: arguments in the get query.
  // param @closure: closure that accepts a jsondata. the closure is called with the json
  // data received from the server.
  func queryServer(url: String, args: [String:String], closure: ((Any?) -> Void)? = nil) {
    // Create request url in order to query API.
    let url = makeGetRequestUsing(url: url, args: args)
    
    let task = URLSession.shared.dataTask(with: url!) { data, response, error in
      guard error == nil else {
        NSLog(error as! String)
        return
      }
      
      do {
        // Get data From the server.
        if let data = data {
          // Parse data from the server as JSON.
          let jsonData = try JSONSerialization.jsonObject(with: data)
          
          // Call callback with jsonData.
          if let f = closure {
            f(jsonData)
          }
        }
      }
      catch {
        print("Error deserializing JSON: \(error)")
      }
    }
    
    task.resume()
  }
  
  // Query the server for an image.
  // param @url: indicated the url to query.
  // param @args: arguments in the get query.
  // returns a UIImage or nil in case of failure.
  func getImage(url: String, args: [String:String]) -> UIImage? {
    // Create request url in order to query API.
    let url = makeGetRequestUsing(url: url, args: args)
    
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
  func makeGetRequestUsing(url sub: String, args: [String:String]) -> URL? {
    let urlComponents = NSURLComponents()
    urlComponents.scheme = "https";
    urlComponents.host = "aui-lekssays.c9users.io";
    urlComponents.path = sub;
    
    // add params
    var items = [NSURLQueryItem]()
    for (key, value) in args {
      items.append(NSURLQueryItem(name: key, value: value))
    }
    urlComponents.queryItems = items as [URLQueryItem]?
    
    return urlComponents.url
  }
}
